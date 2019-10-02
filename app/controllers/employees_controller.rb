class EmployeesController < ApplicationController
  require 'will_paginate/array'
  require 'json'
  def import
  	row_json = {}
    if params["file"].present?
      if File.exists?("public/emp.json")
        @file_data = JSON.parse(File.read("public/emp.json"))
      end
      file_extension = File.extname(params["file"].path) # checking the type of file
    	if file_extension == ".json"  # for json file
        uploaded_file = JSON.parse(File.read(params["file"].path))
        uploaded_file.values.each do |upload_data|
          data = @file_data[upload_data['phone_no'].to_s]
          if data.present?  # if record is already present in the emp.json file then check existence of the respective fields
            upload_data['first_name'] = data['first_name'] if data['first_name'].present? && upload_data['first_name'].blank?
            upload_data['first_name'] = upload_data['first_name'] if data['first_name'].blank? && upload_data['first_name'].present?
            upload_data['last_name'] = data['last_name'] if data['last_name'].present? && upload_data['last_name'].blank?
            upload_data['last_name'] = upload_data['last_name'] if data['last_name'].blank? && upload_data['last_name'].present?
            upload_data['age'] = data['age'] if data['age'].present? && upload_data['age'].blank?
            upload_data['age'] = upload_data['age'] if data['age'].blank? && upload_data['age'].present?
          end
          row_json.merge!(upload_data['phone_no'].to_s => { 'first_name' => upload_data['first_name'], 'last_name' => upload_data['last_name'], 'age' => upload_data['age'],
            'phone_no' => upload_data['phone_no'].to_s })
        end
      elsif file_extension == ".csv" # for csv file
        CSV.foreach(params["file"].path).drop(1).each_with_index do |row, index|
          if @file_data.present?
            data = @file_data[row[3].to_s]
            if data.present?
              row[0] = data['first_name'] if data['first_name'].present? && row[0].blank?
              row[0] = row[0] if data['first_name'].blank? && row[0].present?
              row[1] = data['last_name'] if data['last_name'].present? && row[1].blank?
              row[1] = row[1] if data['last_name'].blank? && row[1].present?
              row[2] = data['age'] if data['age'].present? && row[2].blank?
              row[2] = row[2] if data['age'].blank? && row[2].present?
            end
          end
          row_json.merge!(row[3] => { 'first_name' => row[0], 'last_name' => row[1], 'age' => row[2],
            'phone_no' => row[3]})
        end
      end
      if row_json.present?
        row_json.merge!(@file_data.except!(*row_json.keys)) if @file_data.present?
        File.open("public/emp.json","w") do |f|
          f.write(row_json.to_json)
        end
      end
    end
    redirect_to root_path
  end

  def index
    if File.exists?("public/emp.json")
      file_data = File.read("public/emp.json")
      if params[:page].present?
        @file_data = JSON.parse(file_data).values.paginate(:page => params[:page], :per_page => 4)
      else
        @file_data = JSON.parse(file_data).values.paginate(:page => 1, :per_page => 4)
      end
    end
  end
end
