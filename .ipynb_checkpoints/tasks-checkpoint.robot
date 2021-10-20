# +
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library     RPA.Browser.Selenium
Library     RPA.HTTP
Library     RPA.Tables



# +
*** Variables ***

${url}            https://robotsparebinindustries.com/#/robot-order
${csv_url_orders_file}        https://robotsparebinindustries.com/orders.csv

${img_folder}     ${CURDIR}${/}image
${pdf_folder}     ${CURDIR}${/}pdf
${data_folder}    ${CURDIR}${/}data
${output_folder}  ${CURDIR}${/}output
${orders_file}    ${CURDIR}${/}${data_folder}${/}orders.csv

${zip_file}       ${output_folder}${/}pdf_archive.zip




# -

*** Keywords ***
Get CSVFile orders 
    Download    url=${csv_url_orders_file}           #target_file=${orders_file}    overwrite=True
    ${table}=   Read table from CSV    path=${orders_file}
    [Return]    ${table}


# +
*** Keywords ***
Open the robot order website        
    Open Available Browser      ${url}



        


# -

*** Tasks ***
*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${orders}=    Get CSVFile orders 
    Open the robot order website
    # ${orders}=    Get orders
    # FOR    ${row}    IN    @{orders}
    #     Close the annoying modal
    #     Fill the form    ${row}
    #     Preview the robot
    #     Submit the order
    #     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
    #     Go to order another robot
    # END
    # Create a ZIP file of the receipts

    Log  This is just the beggining
