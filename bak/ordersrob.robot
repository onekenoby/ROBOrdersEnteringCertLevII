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
Library     RPA.PDF
Library     RPA.Robocorp.Vault
Library     OperatingSystem
Library     RPA.Archive
Library     Collections
Library     RPA.Dialogs
# -

*** Variables ***
${img_folder}     ${CURDIR}${/}image
${pdf_folder}     ${CURDIR}${/}pdf
${data_folder}    ${CURDIR}${/}data
${output_folder}  ${CURDIR}${/}output
${orders_file}    ${CURDIR}${/}data/orders.csv
${zip_file}       ${output_folder}${/}pdf_zip_archive.zip


*** Keywords ***
Get The Order Address
    Add heading             Insert the Orders Address
    Add text input          OrderAddress    label=What is the Web Address Order?     placeholder=Instert "https://robotsparebinindustries.com/#/robot-order" here :-)
    ${result}=              Run dialog
    [Return]                ${result.OrderAddress}

*** Keywords ***
Get The CSV Data Order Address
    Add heading             Insert the CSV File Orders Address
    Add text input          DataOrderAddress    label=What is the CSV Data Web Order Address ?     placeholder=Instert "https://robotsparebinindustries.com/orders.csv" here :-)
    ${result}=              Run dialog
    [Return]                ${result.DataOrderAddress}

*** Keywords ***
Get CSVFile orders 
    ${csv_url_orders_file}=     Get The CSV Data Order Address
    Download    ${csv_url_orders_file}         target_file=${data_folder}    overwrite=True
    ${table}=   Read table from CSV    path=${orders_file}
    [Return]    ${table}



*** Keywords ***
Open the robot order website     
    ${url}=         Get The Order Address
    Open Available Browser      ${url}
    #Maximize Browser Window

*** Keywords ***
Close the annoying window
    Wait And Click Button           XPath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

# +
*** Keywords ***
Fill the form 
    [Arguments]     ${myrow}

    # WebPage mapping: define local variables for the UI elements using the 'XPath' strategy
    # --------------------------------------------------------------------------------------------
    # head       -->     //*[@id="head"]
    # body       -->     //*[@id="id-body-1"], //*[@id="id-body-2"], //*[@id="id-body-3"], //*[@id="id-body-4"], //*[@id="id-body-5"], //*[@id="id-body-6"]
    # legs       -->     //*[@id="1634309414895"] or xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    # address    -->     //*[@id="address"]
    # preview    -->     //*[@id="preview"]
    # robot      -->     //*[@id="robot-preview-image"]
    # order      -->     //*[@id="order"]
    # --------------------------------------------------------------------------------------------
    
    # ------------------------------------------------
    # Variables setting 
    # ------------------------------------------------
    Set Local Variable    ${order_no}   ${myrow}[Order number]
    Set Local Variable    ${head}       ${myrow}[Head]
    Set Local Variable    ${body}       ${myrow}[Body]
    Set Local Variable    ${legs}       ${myrow}[Legs]
    Set Local Variable    ${address}    ${myrow}[Address]
    
    Set Local Variable      ${input_head}       //*[@id="head"]
    Set Local Variable      ${input_body}       body
    Set Local Variable      ${input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Set Local Variable      ${input_address}    //*[@id="address"]
    Set Local Variable      ${btn_preview}      //*[@id="preview"]
    Set Local Variable      ${btn_order}        //*[@id="order"]
    Set Local Variable      ${img_preview}      //*[@id="robot-preview-image"]

    # ------------------------------------------------
    # Data entering
    # ------------------------------------------------
    # Head
    Wait Until Element Is Visible   ${input_head}
    Wait Until Element Is Enabled   ${input_head}
    Select From List By Value       ${input_head}           ${head}
    # Boby
    Wait Until Element Is Enabled   ${input_body}
    Select Radio Button             ${input_body}           ${body}
    # Legs
    Wait Until Element Is Enabled   ${input_legs}
    Input Text                      ${input_legs}           ${legs}
    # Address
    Wait Until Element Is Enabled   ${input_address}
    Input Text                      ${input_address}        ${address}


# -

*** Keywords ***
Preview the robot
    # ------------------------------------------------
    # Variables setting 
    # ------------------------------------------------
    Set Local Variable              ${btn_preview}      //*[@id="preview"]
    Set Local Variable              ${img_preview}      //*[@id="robot-preview-image"]
    
    Click Button                    ${btn_preview}
    Wait Until Element Is Visible   ${img_preview}

*** Keywords ***
Submit the order
    # ------------------------------------------------
    # Variables setting 
    # ------------------------------------------------
    Set Local Variable              ${btn_order}        //*[@id="order"]
    Set Local Variable              ${lbl_receipt}      //*[@id="receipt"]

    Click button                    ${btn_order}
    Page Should Contain Element     ${lbl_receipt}

*** Keywords ***
Submit another order
    Set Local Variable      ${btn_order_another_robot}      //*[@id="order-another"]
    Click Button            ${btn_order_another_robot}

*** Keywords ***
Store the receipt as a PDF file
    [Arguments]        ${ORDER_NUMBER}

    Wait Until Element Is Visible   //*[@id="receipt"]
    Log To Console                  Printing ${ORDER_NUMBER}
    ${order_receipt_html}=          Get Element Attribute   //*[@id="receipt"]  outerHTML
    Set Local Variable              ${fully_qualified_pdf_filename}    ${pdf_folder}${/}${ORDER_NUMBER}.pdf
    Html To Pdf                     content=${order_receipt_html}   output_path=${fully_qualified_pdf_filename}

    [Return]    ${fully_qualified_pdf_filename}

*** Keywords ***
Take a screenshot of the robot
    [Arguments]     ${orderid}
    
    # Define local variables for the UI elements
    Set Local Variable      ${lbl_orderid}      xpath://html/body/div/div/div[1]/div/div[1]/div/div/p[1]
    Set Local Variable      ${img_robot}        //*[@id="robot-preview-image"]
    Set Local Variable      ${full_img_filename}    ${img_folder}${/}${orderid}.png
    
    Wait Until Element Is Visible   ${img_robot}
    Wait Until Element Is Visible   ${lbl_orderid} 

    Log To Console                  Capturing Screenshot to ${full_img_filename}
    Capture Element Screenshot      ${img_robot}    ${full_img_filename}
    
    [Return]    ${orderid}  ${full_img_filename}

*** Keywords ***
Embed the robot screenshot to the receipt PDF file
    [Arguments]     ${IMG_FILE}     ${PDF_FILE}

    Log To Console                  Printing Embedding image FUNC ${IMG_FILE} in pdf file ${PDF_FILE}

    Open PDF        ${PDF_FILE}

    # Create the list of files that is to be added to the PDF (here, it is just one file)
    ${myfiles}=       Create List     ${IMG_FILE}:x=0,y=0
   
    Add Files To PDF    ${myfiles}    ${PDF_FILE}     ${True}

    Close PDF           ${PDF_FILE}

*** Keywords ***
Log Out And Close The Browser
    Close Browser

*** Keywords ***
Create a ZIP file
    Archive Folder With ZIP     ${pdf_folder}  ${zip_file}   recursive=True  include=*.pdf

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    
    ${orders}=    Get CSVFile orders 
    Open the robot order website
    FOR    ${row}    IN    @{orders}
         Close the annoying window
         Fill the form    ${row}
         Preview the robot
         Wait Until Keyword Succeeds     10x     2s    Submit the order
         ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
         ${orderid}   ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
         Log To Console        PDF Name         ${pdf}
         Log To Console        Image Name       ${screenshot}
         Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}

         Submit another order
    END
    Close the annoying window
    Create a ZIP file
    Log Out And Close The Browser

















