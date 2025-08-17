class HexColorValidator < ActiveModel::EachValidator
    HEX_REGEX = /\A#[A-Fa-f0-9]{6}\z/
    
    def validate_each(record,attr,value)
        return if value.present? && value.match?(HEX_REGEX)

        record.errors.add(attr,options[:message] || "must be a valid six digit hex code")
    end
end