#!/usr/bin/env ruby 
# encoding: utf-8
require 'nokogiri'

def createInfoXML(delivery_type, documents, localPath, fileName)
  xml = Nokogiri::XML::Builder.new(:encoding => "UTF-8") { |xml| 
    xml.config do
      xml.bulk_api_version "1.00"
      xml.delivery_type delivery_type
      xml.project_name "DP0079_informes_dictamenes_junta_contratacion_administrativa"
      xml.source_id 12513
      xml.documents documents
      xml.content_provider "Daniel Orte"
      xml.content_provider_email "daniorte@gmail.com"
      xml.source "http://www.minhap.gob.es/es-es/servicios/contratacion/junta%20consultiva%20de%20contratacion%20administrativa/informes/Paginas/default.aspx"
      xml.delivery_type delivery_type
      xml.fields do
        xml.field :name => "number", :type => "string"
        xml.field :name => "date", :type => "date"
        xml.field :name => "title", :type => "string"
        xml.field :name => "document_type", :type => "list" do
          xml.valid_value :value_id => "01", :value_description => "Informe"
          xml.valid_value :value_id => "02", :value_description => "Recomendacion"
          xml.valid_value :value_id => "03", :value_description => "Acuerdo"
          xml.valid_value :value_id => "04", :value_description => "Circular"
        end
        xml.field :name => "subject", :type => "list" do
          xml.valid_value :value_id => "01", :value_description => "Cuestiones generales"
          xml.valid_value :value_id => "02", :value_description => "Cuestiones Específicas de los distintos contratos"
          xml.valid_value :value_id => "03", :value_description => "Informes sobre proyectos de disposiciones, recomendaciones, acuerdos y circulares"
        end
		xml.field :name => "sub_subject", :type => "string"
		xml.field :name => "specific_subject", :type => "string"
		xml.field :name => "url", :type => "string"
      end
      xml.selfclosing
    end
  }.to_xml

  out_file = File.new(localPath + "/" + fileName, "w")
  out_file.puts(xml)
  out_file.close
end


def createMetadataXML(docNumber, date, title, document_type, valueIdDT, subSubject, specificSubject, valueIdS, id, url, localPath, fileName)
  xml = Nokogiri::XML::Builder.new(:encoding => "UTF-8") { |xml| 
    xml.document do
      xml.number docNumber
      xml.date date
      xml.title title
      xml.document_type valueIdDT
      xml.subject valueIdS
	  xml.sub_subject subSubject
	  xml.specific_subject specificSubject
      xml.id id
      xml.url url
    end
  }.to_xml

  out_file = File.new(localPath + "/" + fileName, "w")
  out_file.puts(xml)
  out_file.close
end

def createCategoriesDatesXML (categoriesDates, path)
  xml = Nokogiri::XML::Builder.new(:encoding => "UTF-8") { |xml| 
    xml.categories do
    categoriesDates.each do |key, value|
      xml.category do
        xml.name key
        xml.date value
      end
    end
    end
  }.to_xml

  logbookFileName = "/logbook" + Time.now.strftime("%Y%m%d").to_s + ".xml"
  out_file = File.new(path + logbookFileName, "w")
  out_file.puts(xml)
  out_file.close
end

def loadLogBook(filePath)
  f = File.open(filePath)
  doc = Nokogiri::XML(f)
  
  categories = doc.root.xpath("//categories//category")
  logBook = Hash.new("categorias-fechas")
  
  categories.each do |category|
    logBook[category.at_xpath("name").text] = category.at_xpath("date").text
  end
  
  f.close
  return logBook
end