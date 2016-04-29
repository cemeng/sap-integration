#!/Users/cemeng/.rubies/jruby-9.0.5.0/bin/jruby -w

require "ruby-sapjco"
require "awesome_print"
require "yaml"
require "pry"

SapJCo::Configuration.configure(default_destination: :test)

rfc = SapJCo::Function.new("/RBR1/P_AU_RFC_SO_CREATE".to_sym)
out = rfc.execute do |params, tables|
  params[:I_INDICATOR] = " "
  params[:I_VBAK] = {
    AUART: "YCMQ",
    VKORG: "SG10",
    VTWEG: "50",
    SPART: "A3",
    VKBUR: "SG10",
    VKGRP: "SG1",
    # EDATU: "24.03.2016", # don't want to handle the date yet
    KUNAG: "6001548",
    KUNWE: "6001548",
    KUNNR_VE: "13090171",
    KUNNR_SP: "",
    # ANGDT: "01.03.2016",
    # BNDDT: "01.01.2019",
    BSTNK: "PO NUMBER",
    # BSTDK: "24.03.2016",
    VSBED: "1",
    AUTLF: "1",
    IHREZ: "IHREZ",
    KVGR5: "",
    TAXK1: "",
    LIFSK: "",
    FAKSK: "",
    AUGRU: "",
    WAERK: "SGD",
  }
  params[:I_ADRC_AG] = {
    NAME1:	"TEST NAME1 FOR SOLD TO",
    NAME2:	"NAME 2",
    STREET:	"",
    STR_SUPPL1:"",
    POST_CODE1:"",
    CITY:"",
    REGION:"",
    COUNTRY: "DE",
  }
  params[:I_ADRC_WE] = {
    NAME1:	"NAME1 OF SHIP TO",
    NAME2:	"",
    STREET:	"",
    STR_SUPPL1:"",
    POST_CODE1:"",
    CITY:"",
    REGION:"",
    COUNTRY: "DE"
  }
  tables[:IT_ITEM] = [
    {
      POSNR: "000010",
      MATNR: "R044520321",
      ARKTX: 1,
      KDMAT: "AUSTIN 0123",
      PSTYV: "YQ",
      UEPOS: "",
      QTY: 1,
      VRKME: "M",
      KBETR_YN00: 10.01
    },
    {
      POSNR: "000020",
      MATNR: "R987218812",
      ARKTX: 2,
      KDMAT: "AUSTIN DDD",
      PSTYV: "YQ",
      UEPOS: "",
      QTY: 1,
      VRKME: "PC",
      KBETR_YN00: 20.1
    },
    {
      POSNR: "000030",
      MATNR: "R988000496",
      ARKTX: "FREIGHT",
      KDMAT: "R988000496",
      PSTYV: "YQ",
      UEPOS: "",
      QTY: 1,
      VRKME: "PC",
      KBETR_YN00: 30.06
    }
  ]
end
binding.pry
ap out
