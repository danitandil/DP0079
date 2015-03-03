#!/usr/bin/env ruby 
# encoding: utf-8

require 'pdf/reader'

def getDocNumber(text, type, date)
  if (type == "informe")
    result = /\d{1,2}\/\d{1,2}/.match(text)
    return result[0]
  elsif (type == "acuerdo")
    return "acuerdo" + date.gsub('-', '')
  elsif (type == "recomendación")
    return "recomendacion" + date.gsub('-', '')
  elsif (type == "circular")
    return "circular" + date.gsub('-', '')
  else
    return ""
  end
end

def getNumMonth(month)
  monthNumberHash = { "enero" => "01",
            "febrero" => "02",
            "marzo" => "03",
            "abril" => "04",
            "mayo" => "05",
            "junio" => "06",
            "julio" => "07",
            "agosto" => "08",
            "septiembre" => "09",
            "octubre" => "10",
            "noviembre" => "11",
            "diciembre" => "12"
          }
  return monthNumberHash[month]  
end

def getDocDate(text)
  year = "yyyy"
  month = "mm"
  day = "dd"
  text = text.downcase
  text = text.gsub('.', '')
  r = /(\d+{1,2})\s*(de|)\s*(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\s*(de|)\s*(\d{0,4})/
  
  if(r.match(text) != nil)
    date = r.match(text)[0]
    date = date.gsub('de', '')
    date = date.gsub('  ', ' ')
    splitedDate = date.split(" ")

    if(splitedDate[2] != nil)
      year = splitedDate[2]
    else
      return "no_date"
	end    
  
    if(splitedDate[1] != nil)
      month = getNumMonth(splitedDate[1])
    else
      return "no_date"
	end

    if(splitedDate[0] != nil)
      day = splitedDate[0]
      if day.to_i < 10
        day = "0" + day
      end
	else
      return "no_date"
    end
  else
    return "no_date"
  end

  result = year + "-" + month + "-" + day
  return result  
end

def getDocType(text)
  text = text.downcase
  r = /(informe|recomendación|acuerdo|circular)/
  type = r.match(text)[0]
  return type
end

def getDocTypeValueId(type)
  type = type.downcase
  docTypeValueIdHash = { "informe" => "01",
            "recomendación" => "02",
            "acuerdo" => "03",
            "circular" => "04"
          }
  return docTypeValueIdHash[type]
end



def saveDocument(urlDoc, localPath, docName)
  urlFile = localPath + "/" + docName
  urlDoc = encodeReplace(urlDoc)  
  
  File.open(urlFile, "wb") do |saved_file|
    begin
      ### The following "open" is provided by open-uri ###
      open(urlDoc, "rb") do |read_file|
        saved_file.write(read_file.read)
    end  
    rescue 
      puts "ERROR: Documento no disponible: " + urlDoc
      return false  
    end
  end
  return true
end


def getSubjectDescription(subjectId)
  if subjectId == "01"
  return "Cuestiones generales"
  elsif subjectId == "02"
    return "Cuestiones Específicas de los distintos contratos"
  else 
  return "Informes sobre proyectos de disposiciones, recomendaciones, acuerdos y circulares"
  end
end


def getSubjectId(text)
  number = text.split(". ")[0].to_i
  if number <= 20
  return "01"
  elsif number <= 30
    return "02"
  else 
  return "03"
  end  
end

def encodeReplace(text)
  text = text.gsub('á', '%C3%A1')
  text = text.gsub('é', '%C3%A9')
  text = text.gsub('í', '%C3%Ad')
  text = text.gsub('ó', '%C3%B3')
  text = text.gsub('Ã³', '%C3%B3')
  text = text.gsub('ú', '%C3%BA')
  text = text.gsub('º', '%C2%BA')
  return text
end


def saveTxtFromPdf(pdfFileName, txtFileName)
  result = ""
  PDF::Reader.open(pdfFileName) do |reader|
    reader.pages.each do |page|
      result = result + page.raw_content
    end
  end
  out_file = File.new(txtFileName, "w")
  out_file.puts(result)
  out_file.close
end

def isPdf(url)
  r = /.pdf$/
  if r.match(url) != nil
    return true
  end
  return false
end

def isCompleteDate(url)
  r = /(\d{4,4})-(\d+{2,2})-(\d+{2,2})/
  if r.match(url) != nil
    return true
  end
  return false
end

def getNewestDate(date1, date2)
  if !isCompleteDate(date1)
    return date2
  elsif !isCompleteDate(date2)
    return date1
  elsif date1 >= date2
  return date1
  else 
  return date2
  end
end

def isNewDocument(logBook,categoria,docDate)
  return isCompleteDate(docDate) && (docDate > logBook[categoria])  
end

def createCompletedFile(path)
  out_file = File.new(path + "/COMPLETED", "w")
  out_file.close
end

def removeNumeration(text)
  r = /\d*\.*\d*\.*\d*\.*/
  if(r.match(text) != nil)
    numeration = r.match(text)[0]
	return text.sub(numeration, "")
  end
end
