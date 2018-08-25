module Hybridge
  module Batch
    class Entry

      def initialize(work, files, current_user, package_location)
        @work = work
        @files = files
        @current_user = current_user
        @package_location = package_location

        process!
      end

      def process!
        work_type = @work["Object Type"].constantize.new
        work_form = ("Hyrax::" + @work["Object Type"] + "Form").constantize

        work_attributes = field_attributes(work_form, work_type)

        # TODO: check for required_fields and send error

        work_type.apply_depositor_metadata(@current_user)
        work_type.attributes = work_attributes
        work_type.save

        process_files! work_type unless @files.nil?
      end

      def field_attributes(work_form, work_type)
        data = {}
        @work.each do |key, attribute|
          field_sym = field_to_sym(key)
          if (field_sym.nil? || attribute.nil? || attribute.empty? || key.to_s.include?("Object Type") || !work_form.terms.include?(field_sym))
            next
          elsif(work_type.send(field_sym).nil?)
            data[field_sym] = attribute
          else
            data[field_sym] = attribute.split "; "
          end
        end
        data
      end

      def file_location(filename)
        File.join(@package_location, filename)
      end

      def process_files!(work_type)
        work_permissions = work_type.permissions.map(&:to_hash)
        @files.each do |file_object|
          file_path = file_location(file_object["Filename"])
          if !File.file?(file_path)
            # TODO: send error if missing file
            next
          end

          file = Hyrax::UploadedFile.new(user: @current_user, file: File.new(file_path))
          file_actor = Hyrax::Actors::FileSetActor.new(FileSet.create, @current_user)
          file_actor.create_metadata
          file_actor.create_content(file)
          file_actor.attach_to_work(work_type)
          file_actor.file_set.permissions_attributes = work_permissions
          file.update(file_set_uri: file_actor.file_set.uri)
        end
      end

      def field_to_sym(field)
        if field.downcase == "abstract or summary"
          field = "description"
        elsif field.downcase == "abstract / summary"
          field = "description"
        elsif field.downcase == "location"
          field = "based_near"
        end

        field.downcase.strip.gsub(/\s/,'_').to_sym
      end

    end
  end
end
