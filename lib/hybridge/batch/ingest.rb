module Hybridge
  module Batch
    class Ingest

      def initialize(file, collection_id, current_user)
        @file = file
        @collection_id = collection_id
        @current_user = current_user
        load!
      end

      def load!

        return unless staged? || processing?

        processing!
        @works = []
        @files = {}
        good_work = false

        @csv = CSV.parse(File.read(@file), headers: true, encoding: 'utf-8').map(&:to_hash)
        @csv.each do |row|
          type = row.first.last
          if type.nil?
            good_work = false
            next
          elsif Hyrax.config.registered_curation_concern_types.include? type
            good_work = true
            row.delete("Filename")
            @works << row
            @files[@works.length] = []
          elsif type.include? "File"
            if good_work
              row.delete("Object Type")
              @files[@works.length] << row
            end
          else
            good_work = false
            message = "Unknown work type '#{type}'"
            Hyrax::MessengerService.deliver(User.batch_user, @current_user, message, "HyBridge Warning: Unknown work type")
          end
        end

        @works.each_with_index do |work, index|
          Entry.new(work, @files[index+1], @collection_id, @current_user, File.dirname(@file))
        end
        processed!
      end

      def processing!
        new_file = Pathname(@file).sub_ext '' + ".processing"
        File.rename(@file, new_file) unless File.file?(new_file)
        @file = new_file
      end

      def processed!
        new_file = Pathname(@file).sub_ext '' + ".processed"
        File.rename(@file, new_file)
        @file = new_file
      end

      def processing?
        File.file?(Pathname(@file).sub_ext '' + ".processing")
      end

      def processed?
        File.file?(Pathname(@file).sub_ext '' + ".processed")
      end

      def staged?
        File.file?(Pathname(@file).sub_ext '' + ".staged")
      end

    end
  end
end