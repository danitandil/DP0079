#!/usr/bin/env ruby 
# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'logger'
require 'fileutils'

_path = File.dirname(__FILE__)
require _path + '/util'
require _path + '/xmlUtil'
   
###log###
log = Logger.new(_path + '/log.txt')
log.debug "Log file created"
logStatistics = Logger.new(_path + '/logStatistics.txt')
logStatistics.debug "Log file created"

host = "http://www.minhap.gob.es"
url = host + "/es-es/servicios/contratacion/junta%20consultiva%20de%20contratacion%20administrativa/informes/Paginas/default.aspx"
page = Nokogiri::HTML(open(url)) 
page.encoding = 'UTF-8'

_projectName = "DP0079"

_root = _path + "/" + _projectName + "/initial_dump"
deliveryType = "initial_dump"
categoriesDates = Hash.new("categorias-fechas")
logBook = nil

###crear carpeta: update o initial dump###
p1 = ARGV[0]
if (p1 != nil)
  p1 = p1.downcase
  if (p1 == "update")
    _root = _path + "/" + _projectName + "/update"
	deliveryType = "update"
	if (p2 = ARGV[1])
	  logBook = loadLogBook(_path + "/" + p2)
	else
	  puts "ERROR: falta parámetro que indica la ubicación del fichero de bitácora o logbook"
	  return
	end
  else
    puts "ERROR: parámetro incorrecto. Intente con 'update'"
    return
  end
end
FileUtils.mkdir_p _root

###crear carpeta documents###
_documents = _root + '/' + "documents"
FileUtils.mkdir_p _documents

docCounter = 0
docsUndated = 0
downloadedDocs = 0
newestCategoryDate = ""

categorias = page.search(".seccion_texto ul ul li").map do |li|
  
  ###log###
  log.debug "LI:" + li.text
  categoria = li.text
  subjectId = getSubjectId(li.text)
  
  info_link = li.search('a').map do |a|
    
	###log###
	log.debug "CATEGORIA-HEREF:" + a['href']    
    log.debug "CATEGORIA-TEXT:" + a.text
    puts "CATEGORIA-TEXT:" + a.text
		
	subSubject = a.text
	linkCategoria = encodeReplace(a['href'])
	
    page_informes = Nokogiri::HTML(open(host + linkCategoria))
	page_informes.encoding = 'UTF-8'
	specificSubject =  ""
	
	elements = page_informes.search("div #ctl00_PlaceHolderMain_ldwTexto")
	
	elements.children.each do |node|
		
	  if node.name == "p"
		specificSubject = node.search("strong").text
		specificSubject = removeNumeration(specificSubject)
	  elsif node.name == "ul"
		node.children.each do |li|
		  if li.name = "li"
		
		    ###log###
		    log.debug "INFORME-LI:" + li.text
		
		      info_link = li.search('a').map do |a|
		   
		      title = a.text
		      url = (host + a['href'])
			  
			  textLink = li.text
  		      docType = getDocType(textLink)
			  docDate = getDocDate(textLink)
			  docNum = getDocNumber(textLink, docType, docDate)
			  
			  if docDate == "no_date"
			    docsUndated += 1
			  end

		      newestCategoryDate = getNewestDate(newestCategoryDate, docDate)
						  
			  docId = docNum.gsub('/', '')
			  valueIdDT = getDocTypeValueId(docType)

			  if (deliveryType != "update" || isNewDocument(logBook,categoria,docDate))

				###crear carpeta <yyyy-mm-dd>###
				FileUtils.mkdir_p _documents + '/' + docDate

				###crear carpeta <id_document>###
				docNumFolderName = _documents + '/' + docDate + '/' + docId
				FileUtils.mkdir_p docNumFolderName

				###crear METADATA-<id-document>.xml###
				fileName = "METADATA-" + docId + ".xml"
				subjectDescription = getSubjectDescription(subjectId)
				createMetadataXML(docNum, docDate, title, docType.capitalize, valueIdDT, subSubject, specificSubject, subjectId, docId, url, docNumFolderName, fileName)
		  
			    if isPdf(url)		  
				  ###crear carpeta contents###
				  _contents = docNumFolderName + '/contents'
				  FileUtils.mkdir_p _contents
			  
				  ###guardar pdf doc###
				  pdfFileName = docId + ".pdf"
				  if saveDocument(url, _contents, pdfFileName)
				    ###guardar txt doc###
				    txtFileName = docId + ".txt"
				    #saveTxtFromPdf(_contents + "/" + pdfFileName, _contents + "/" + txtFileName)
				    downloadedDocs += 1
			      else
				    log.debug "ERROR, Documento no disponible: " + url
			      end
			    end
		  
			    ###log###
			    log.debug "TYPE:" + docType
			    log.debug "NUM:" + docNum
			    log.debug "DATE:" + docDate
			    puts docNum

			  docCounter += 1

		    end
		  
		    end			
		  end
		end
	  
	  end

	  
	end    

    ###log###
	log.debug "--------------------------------------------------------------------"
    puts "--------------------------------------------------------------------"
	
  end
  categoriesDates[categoria] = newestCategoryDate
end

createCategoriesDatesXML(categoriesDates, _path)

logStatistics.debug "Docs Undated: " + docsUndated.to_s
logStatistics.debug "Docs total: " + docCounter.to_s

###crear INFO.xml###
createInfoXML(deliveryType, docCounter, _root, "INFO.xml")

###crear archivo COMPLETE###
createCompletedFile(_root)

###log###
log.debug "Number of downloaded documents: " + downloadedDocs.to_s
puts "Number of downloaded documents: " + downloadedDocs.to_s
log.debug "END"
puts "END"

