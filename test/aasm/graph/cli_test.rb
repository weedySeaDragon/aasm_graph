require_relative "../../test_helper"

class CLITest < Minitest::Test

  TEST_CLASS_FILE_OPTIONS = [File.join('test', 'fixtures', 'job')]
  TEST_CLASS_OPTIONS = ['Job']


  def test_graph_file_is_created

    Dir.mktmpdir do |dir|

      file = File.join(dir, 'job.jpg')

      AASM::Graph::CLI.new(
          class_names: TEST_CLASS_OPTIONS,
          class_files: TEST_CLASS_FILE_OPTIONS,
          output_path: dir
      ).run

      assert File.exists?(file), "Output file #{file} wasn't created"
    end
  end


  def test_class_files_required
    result = -1
    Dir.mktmpdir do |dir|

      result = AASM::Graph::CLI.new(
          class_names: TEST_CLASS_OPTIONS,
          class_files: TEST_CLASS_FILE_OPTIONS,
          output_path: dir
      ).run

      assert_equal(result, 0, "Could not require #{TEST_CLASS_FILE_OPTIONS.first} file.")
    end
  end


  def test_bad_class_file

    assert_raises(LoadError) {

      Dir.mktmpdir do |dir|
        result = AASM::Graph::CLI.new(
            class_names: TEST_CLASS_OPTIONS,
            class_files: [File.join('test', 'fixtures', 'DOES-NOT-EXIST')],
            output_path: dir
        ).run
      end
    }
  end


  def test_class_found
    result = -1
    Dir.mktmpdir do |dir|

      result = AASM::Graph::CLI.new(
          class_names: TEST_CLASS_OPTIONS,
          class_files: TEST_CLASS_FILE_OPTIONS,
          output_path: dir
      ).run
    end

    assert_equal(result, 0)
  end


  def test_bad_class
    assert_raises(NameError) {
      Dir.mktmpdir do |dir|

        result = AASM::Graph::CLI.new(
            class_names: ['BadClassDoesNotExist'],
            class_files: TEST_CLASS_FILE_OPTIONS,
            output_path: dir
        ).run
      end
    }
  end


  # TODO give the output file directory

  # TODO test the information generated in the .dot file is correct

end
