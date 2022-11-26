class Authentication
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, field_name: -1}
  end

  def self.input_group
    [5, %w[dated signature seal certificate verification]]
  end

  def self.config_certificate(k, tb_hsh, k_hsh, input_group, context)
  	config_certificate_title(tb_hsh)
  end

  def self.config_certificate_title(tb_hsh, tag_key='tagline')
    if v = detect_swap(tb_hsh[tag_key], [['with Letter of Authenticity', 'w/LOA'], ['with Certificate of Authenticity', 'w/COA']])
      tb_hsh['invoice_tagline'] = v
      tb_hsh['search_tagline'] = v
    end
  end

  def self.config_dated(k, tb_hsh, k_hsh, input_group, context)
    config_auth_params(k, tb_hsh, k_hsh, context)
  end

  def self.config_verification(k, tb_hsh, k_hsh, input_group, context)
    config_auth_params(k, tb_hsh, k_hsh, context)
  end

  def self.config_auth_params(k, tb_hsh, k_hsh, context)
    if k_hsh.any? && tb_hsh.any?
      tb_hsh.transform_values!{|tag_val| config_auth_value(context, k, "#{tag_val} (#{k_hsh.values[0]})")}
    else
      tb_hsh.clear
    end
  end

  def self.config_auth_value(context, k, v)
    k=='dated' ? format_date(context, v) : v
  end

  def self.format_date(context, v)
    case
      when context[:numbered_signed]; v+','
      when context[:signed] || context[:numbered]; v+' and'
      else v+'.'
    end
  end

  def self.config_signature(k, tb_hsh, k_hsh, input_group, context)
  	#
  end

  def self.config_animator_seal(k, tb_hsh, k_hsh, input_group, context)
    tb_hsh.transform_values!{|tag_val| config_animator_seal_value(tag_val, context)}
  end

  def self.config_animator_seal_value(tag_val, context)
    !context[:sports_seal] ? tag_val+'.' : tag_val
  end

  def self.config_sports_seal(k, tb_hsh, k_hsh, input_group, context)
    tb_hsh.transform_values!{|tag_val| config_sports_seal_value(tag_val, context)}
  end

  def self.config_sports_seal_value(tag_val, context)
  	tag_val = tag_val.sub('This piece bears', 'and') if context[:animator_seal]
    tag_val+'.'
  end

  class SelectField < Authentication
    class Dated < SelectField
      def self.target_tags(f_name)
        {body: f_name}
      end

      class StandardDated < Dated
        def self.targets
          ['dated', 'dated circa']
        end
      end
    end

    class Signature < SelectField
      def self.target_tags(f_name)
        {tagline: tagline(f_name), body: body(f_name)}
      end

      def self.tagline(f_name)
        case
          when %w[estate authorized].any? {|i| f_name.split(' ').include?(i)}; 'Signed'
          when f_name == 'unsigned'; "(#{f_name.capitalize})"
          else str_edit(str:f_name, skip:['and']);
        end
      end

      def self.body(f_name)
        case
          when %w[plate authorized].any? {|i| f_name.split(' ').include?(i)}; "bearing the #{f_name} signature of the artist"
          when f_name.split(' ').include?('thumbprinted'); "hand signed and bearing the thumbprint of the artist"
          when f_name == 'unsigned'; "This piece is unsigned."
          when f_name.index('estate'); f_name
          else "#{f_name} by the artist";
        end
      end

      class StandardSignature < Signature
        def self.targets
          ['hand signed', 'hand signed inverso', 'plate signed', 'authorized', 'estate signed', 'estate signed inverso', 'signed & thumbprinted', 'unsigned']
        end
      end

      # class WileySignature < Signature
      #   def self.targets
      #     ['hand signed and thumbprinted', 'hand signed', 'hand signed inverso', 'unsigned']
      #   end
      # end
    end

    class Certificate < SelectField
      def self.target_tags(f_name)
        {tagline: tagline(f_name), body: body(f_name)}
      end

      def self.tagline(f_name)
        "with #{str_edit(str: f_name, swap: swap_list, skip: %w[from of])}"
      end

      def self.body(f_name)
        f_name = swap_str(f_name, swap_list)
        f_name.index('Britto Stamp') ? "This piece bears an #{f_name}." : "Includes #{f_name}."
      end

      def self.swap_list
        ['COA', 'Certificate of Authenticity', 'LOA', 'Letter of Authenticity']
      end

      class StandardCertificate < Certificate
        def self.targets
          ['LOA', 'COA']
        end
      end

      class PeterMaxCertificate < Certificate
        def self.targets
          ['LOA', 'COA from Peter Max Studios']
        end
      end

      class BrittoCertificate < Certificate
        def self.targets
          ['LOA', 'COA from Britto Rommero Fine Art', 'official Britto Stamp inverso']
        end
      end
    end

    class Seal < SelectField
      def self.target_tags(f_name)
        {body: body(f_name)}
      end

      def self.body(f_name)
        "This piece bears the official #{f_name} seal"
      end

      class AnimatorSeal < Seal
        def self.targets
          ['Warner Bros.', 'Looney Tunes']
        end
      end

      class SportsSeal < Seal
        def self.targets
          ['MLB', 'NFL', 'NBA', 'NHL']
        end
      end
    end

    #note: another field designating: includes/bears/bears inverso/
    class Verification < SelectField
      def self.target_tags(f_name)
        {body: body(f_name)}
      end

      def self.body(f_name)
        "This piece is authenticated by a unique #{f_name}"
      end

      class VerificationType < Verification
        def self.targets
          ['verification number', 'verification number inverso', 'registration number', 'registration number inverso']
        end
      end
    end
  end

  class TextField < Authentication
    class Signature < TextField
      class Signer < Signature
        def self.targets
        end
      end

      class SignerTag < Signature
        def self.targets
        end
      end
    end

    class Verification < TextField
      class VerificationNumber < Verification
        def self.targets
        end
      end
    end

    class Dated < TextField
      class Date < Dated
        def self.targets
        end
      end
    end
  end

  class FieldSet < Authentication
    #new
    class Signature < FieldSet
      class StandardSignature < Signature
        def self.targets
          [%W[SelectField Signature StandardSignature], %W[TextField Signature Signer], %W[TextField Signature SignerTag]]
        end
      end
    end

    class Dated < FieldSet
      class StandardDated < Dated
        def self.targets
          [%W[SelectField Dated StandardDated], %W[TextField Dated Date]]
        end
      end
    end

    class Seal < FieldSet
      class AnimationSeal < Seal
        def self.targets
          [%W[SelectField Seal AnimatorSeal], %W[SelectField Seal SportsSeal]]
        end
      end
    end

    class Verification < FieldSet
      class StandardVerification < Verification
        def self.targets
          [%W[SelectField Verification VerificationType], %W[TextField Verification VerificationNumber]]
        end
      end
    end

    class GroupA < FieldSet
      def self.attrs
        {kind: 0}
      end

      # class StandardAuthentication < GroupA
      #   def self.targets
      #     [%W[FieldSet Dated StandardDated], %W[SelectField Signature StandardSignature], %W[SelectField Certificate StandardCertificate]]
      #   end
      # end

      class StandardAuthentication < GroupA
        def self.targets
          [%W[FieldSet Dated StandardDated], %W[FieldSet Signature StandardSignature], %W[SelectField Certificate StandardCertificate]]
        end
      end

      class PeterMaxAuthentication < GroupA
        def self.targets
          [%W[FieldSet Verification StandardVerification], %W[SelectField Signature StandardSignature], %W[SelectField Certificate PeterMaxCertificate]]
        end
      end

      class BrittoAuthentication < GroupA
        def self.targets
          [%W[SelectField Signature StandardSignature], %W[SelectField Certificate BrittoCertificate]]
        end
      end

      # class StandardSericelAuthentication < GroupA
      #   def self.targets
      #     [%W[SelectField Signature StandardSignature], %W[SelectField Seal AnimatorSeal], %W[SelectField Certificate StandardCertificate]]
      #   end
      # end

      class StandardSericelAuthentication < GroupA
        def self.targets
          [%W[FieldSet Signature StandardSignature], %W[SelectField Seal AnimatorSeal], %W[SelectField Certificate StandardCertificate]]
        end
      end

      # class SericelAuthentication < GroupA
      #   def self.targets
      #     [%W[FieldSet Dated StandardDated], %W[SelectField Signature StandardSignature], %W[FieldSet Seal AnimationSeal], %W[SelectField Certificate StandardCertificate]]
      #   end
      # end

      class SericelAuthentication < GroupA
        def self.targets
          [%W[FieldSet Dated StandardDated], %W[FieldSet Signature StandardSignature], %W[FieldSet Seal AnimationSeal], %W[SelectField Certificate StandardCertificate]]
        end
      end
    end
  end
end


  # def self.config_auth_params(k, v, auth_hsh, context, d_hsh)
  #   #d_hsh.merge!({k=> auth_hsh.transform_values!{|tag_val| config_auth_value(context, k, "#{v} (#{tag_val})")}})
  #   d_hsh[k] = auth_hsh.transform_values!{|tag_val| config_auth_value(context, k, "#{v} (#{tag_val})")}
  #   #context[k.to_sym] = true
  # end

  # def self.config_authenication(k, auth_hsh, input_group, context, d_hsh)
  # 	tb_hsh = Item.new.slice_valid_subhsh!(auth_hsh, *Item.new.tb_keys)
  #   if %w[dated verification].include?(k) && auth_hsh.any?
  #     d_hsh.merge!({k=> auth_hsh.transform_values!{|tag_val| "#{v} (#{tag_val})"}})
  #   elsif %w[animator_seal sports_seal].include?(k)
  #     config_seal(k, tb_hsh, context, d_hsh)
  #   end
  # end
