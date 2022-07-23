class Authentication
  include ClassContext
  include FieldSeed
  include Hashable
  include Textable

  def self.attrs
    {kind: 2, type: 1, f_name: -1}
  end

  def self.input_group
    [5, %w[dated signature seal certificate verification]]
  end

  def self.config_auth_params(k, v, auth_hsh, context, d_hsh)
  	d_hsh.merge!({k=> auth_hsh.transform_values!{|tag_val| "#{v} (#{tag_val})"}})
    context[k.to_sym] = true
  end

  def self.config_authenication(k, auth_hsh, input_group, context, d_hsh)
  	tb_hsh = Item.new.slice_valid_subhsh!(auth_hsh, *Item.new.tb_keys)
    if %w[dated verification].include?(k) && auth_hsh.any?
      d_hsh.merge!({k=> auth_hsh.transform_values!{|tag_val| "#{v} (#{tag_val})"}})
      context[k.to_sym] = true
    elsif %w[animator_seal sports_seal].include?(k)
      config_seal(k, tb_hsh, context, d_hsh)
    end
  end

  def self.config_seal(k, tb_hsh, context, d_hsh)
  	d_hsh.merge!({k=> tb_hsh.transform_values!{|tag_val| config_seal_value(k, tag_val, context)}})
  end

  # def self.config_seal_params(seal_key, seal_hsh, context, d_hsh)
  # 	seal_hsh.each do |tag_key, tag_val|
  #     Item.case_merge(d_hsh, config_seal_value(seal_key, tag_val, context), seal_key, tag_key)
  #   end
  # end

  def self.config_seal_value(seal_key, tag_val, context)
  	seal_key=='animator_seal' ? config_animator_seal_value(tag_val, context) : config_sports_seal_value(tag_val, context)
  end

  def self.config_animator_seal_value(tag_val, context)
    !context[:sports_seal] ? tag_val+'.' : tag_val
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
          when f_name == 'unsigned'; "This piece is unsigned."
          when f_name.index('estate'); f_name
          else "#{f_name} by the artist";
        end
      end

      class StandardSignature < Signature
        def self.targets
          ['hand signed', 'hand signed inverso', 'plate signed', 'authorized', 'estate signed', 'estate signed inverso', 'unsigned']
        end
      end

      class WileySignature < Signature
        def self.targets
          ['hand signed and thumbprinted', 'hand signed', 'hand signed inverso', 'unsigned']
        end
      end
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

      class StandardAuthentication < GroupA
        def self.targets
          [%W[FieldSet Dated StandardDated], %W[SelectField Signature StandardSignature], %W[SelectField Certificate StandardCertificate]]
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

      class WileyAuthentication < GroupA
        def self.targets
          [%W[SelectField Signature WileySignature], %W[SelectField Certificate StandardCertificate]]
        end
      end

      class StandardSericelAuthentication < GroupA
        def self.targets
          [%W[SelectField Signature StandardSignature], %W[SelectField Seal AnimatorSeal], %W[SelectField Certificate StandardCertificate]]
        end
      end

      class SericelAuthentication < GroupA
        def self.targets
          [%W[FieldSet Dated StandardDated], %W[SelectField Signature StandardSignature], %W[FieldSet Seal AnimationSeal], %W[SelectField Certificate StandardCertificate]]
        end
      end
    end
  end
end
