Install gem locally:
```
cd vendor
jruby -S gem install logging-facade
jruby -S gem install ruby-sapjco
```
Also install pry and awesome_print as needed

```
export CLASSPATH=$CLASSPATH:~/prj/sap-integration/jar
```

Monkey patches:

* ruby-sapjco-env.rb line 7 should be Logger.logger.info
* ruby-sapjco.rb hash_into_jco_record function
```
    def hash_into_jco_record(hash, jco_record)
      hash.each do |key, value|
        if (value.class == Hash)
          value.each do |hash_key, hash_value|
            jco_record.get_structure(key.to_s).set_value(hash_key.to_s, hash_value.to_s)
          end
        else
          jco_record.set_value(key.to_s, value)
        end
      end
    end
```
* ruby-sapjco.rb: parse_sap_record_structure function
```
  return field_list.to_xml if field_list.class.to_s == "Java::ComSapConnJcoRt::DefaultTable"
```
