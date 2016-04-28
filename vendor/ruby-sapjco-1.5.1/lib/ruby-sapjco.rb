# require 'ruby-sapjco'
require 'ruby-sapjco-config'
require 'ruby-sapjco-assist'
require 'logging-facade'
require 'haml'
require 'launchy'

module SapJCo 
  class Function
    include  LoggingFacade::Logger

    def initialize(function_name, destination_name=SapJCo::Configuration.configuration[:default_destination])
      @function_name = function_name
      @destination_assistant = DestinationAssistant.new(destination_name)
      @func = @destination_assistant.destination.repository.get_function(@function_name.to_s)
    end

    # Executes the SAP RFC.  Optionally: you can pass in a block that takes
    # a hash which can be used to set the import parameter list for this function
    # call.
    def execute(import_parameters = {}, table_parameters = {})
      raise "RFC #{@function_name.to_s} is not available on the target system." if @func.nil?

      yield(import_parameters, table_parameters) if block_given?

      hash_into_jco_record(import_parameters, @func.get_import_parameter_list)

      hash_into_jco_table(table_parameters, @func.get_table_parameter_list)
      
      @func.execute @destination_assistant.destination

      format_jco_response(@func)
    end

    def metadata
      out = {}
      template = FunctionMetaData.new(@func)
      out[:function]=template.name
      out[:import_parameters]=template.import_params_info
      out[:export_parameters]=template.export_params_info
      out[:tables]=template.table_info
      out
    end

    def help(open=false)
      template = File.read("#{File.dirname(__FILE__)}/../templates/function_doc.haml")
      engine = Haml::Engine.new(template)
      html = engine.render DocumentationHelper.new, :metadata => metadata

      File.open("#{@function_name}.html", "w") do |file|
        file.write html
        logger.info "Help file path #{file.path}"        
      end

      if open
        Launchy.open(file.path)
      end

      html
    end

    private

    # Recursively converts JCoRecord types to Ruby Hashes and Arrays (JCoTable instances).
    def parse_sap_record_structure(field_list)
      out = Hash.new
      field_list.each do |field|
        if field.value.class.include?(com.sap.conn.jco.JCoTable)
          table = field.get_table
          table_array = []
          begin
            table_array << parse_sap_record_structure(table)
          end while table.next_row
          out[field.name.to_sym] = table_array
        elsif  field.value.class.include?(com.sap.conn.jco.JCoRecord)
          out[field.name.to_sym] = parse_sap_record_structure field.value
        else
          out[field.name.to_sym] = field.value
        end
      end unless field_list.nil?
      out
    end
    
    def hash_into_jco_record(hash, jco_record)
      hash.each do |key, value|
        jco_record.set_value(key.to_s, value)
      end
    end

    def hash_into_jco_table(hash, jco_parameter_list)
      hash.each do |key, value|
        jco_table = jco_parameter_list.get_table key.to_s    
        raise "No such input table #{key.to_s} exists." if !jco_table           
        value.each do |row|
          jco_table.append_row          
          hash_into_jco_record(row, jco_table)  
        end        
      end      
    end

    def format_jco_response(rfc)
      out = parse_sap_record_structure rfc.get_export_parameter_list
      out.merge!(parse_sap_record_structure(rfc.get_table_parameter_list))
      out
    end
  end

  class FunctionMetaData

    def initialize(function)
      @template = function.get_function_template
      @import_params = @template.get_import_parameter_list
      @export_params = @template.get_export_parameter_list
      @tables = @template.get_table_parameter_list
    end

    def name
      @template.get_name
    end

    def table_info
      parse_parameters @tables
    end

    def import_params_info

      parse_parameters @import_params
    end

    def export_params_info
      parse_parameters @export_params
    end

    def parse_parameters(parameter_list)
      out = {}
      parameter_list.each do |param|
        info = {}
        info[:type] = param.type
        info[:description] = param.description
        #info[:import?] = param.import?
        if param.fields?
          fields = {}
          info[:fields] = fields
          param.each do |column|
            fields[column.name.to_sym]={:type=>column.type,
                                        :description=>column.description}
          end
        end
        out[param.name.to_sym]=info
      end unless parameter_list.nil?
      out
    end

  end

  class DocumentationHelper
    def render(template_name, args)
      template = File.read("#{File.dirname(__FILE__)}/../templates/#{template_name.to_s}.haml")
      engine = Haml::Engine.new(template)
      engine.render Object.new, args
    end
  end
end
