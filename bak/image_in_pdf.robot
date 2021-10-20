*** Settings ***
Library         RPA.PDF

# +
*** Variables ***
${img_folder}       ${CURDIR}${/}image
${pdf_folder}       ${CURDIR}${/}pdf

${IMG_FILE}        ${img_folder}${/}1.png       
${PDF_FILE}        ${pdf_folder}${/}1.pdf
# -

*** Keywords ***
Embed the robot screenshot to the receipt PDF file
    [Arguments]     ${IMG_FILE}     ${PDF_FILE}

    Log To Console                  Printing Embedding image ${IMG_FILE} in pdf ${PDF_FILE}

    Open PDF        ${PDF_FILE}

    # Create the list of files that is to be added to the PDF (here, it is just one file)
    ${myfiles}=       Create List     ${IMG_FILE}:x=0,y=0
   
    Add Files To PDF    ${myfiles}    ${PDF_FILE}     ${True}

    Close PDF           ${PDF_FILE}

*** Tasks ***
Processing Results 
    Embed the robot screenshot to the receipt PDF file    ${IMG_FILE}    ${PDF_FILE}
    Log    ...i files sono una immagine ${IMG_FILE} e un pdf ${PDF_FILE}





