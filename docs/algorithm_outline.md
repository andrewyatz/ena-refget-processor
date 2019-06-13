# Processing methodology for EMBL records from FTP

Target expanded_con sequence files first before moving to anything else.

1. List all `*.dat.gz` files in ftp://ftp.ebi.ac.uk/pub/databases/ena/sequence/release/expanded_con
2. For each found file
    - Download the .dat.gz file and accompanying .lis file (for double checking)
    - Loop each record
    - Grab accession, version, sequence (other fields perhaps)
    - Checksum sequence (md5, trunc512, sha512)
    - Create JSON blob
    - Write sequence and JSON to disk (note use %s/%s/%s format to allow efficient writing and not crashing filesystems)
    - Consider checksum file to ensure write roundtrip has worked
    - If version != 1
    - Record accession as one to further interrogate
    - Log processing of record
    - If failed at any point write into an error log alongside the file that failed
    - Perhaps can we push the record somewhere ... not sure
    - Success means write into a basic file perhaps same content
3. For list of non-version 1 records
    - Query ENA REST service for versions at https://www.ebi.ac.uk/ena/browser/api (e.g. https://www.ebi.ac.uk/ena/browser/api/versions/ML136216)
    - Loop for all entries
    - If entry has a FASTA endpoint write to log to further process as above
    - Use FASTA endpoint to retrieve the sequence as above (share the same library)
    - Log success of record processing
    - If entry does not have a FASTA endpoint write into a missing log to pass onto ENA
    - Log accession and all essential metadata bar sequence and derived data

# Log writing/processing

- Each process will have its own log written into a central location
- Each central location will be formatted consistently for the log format
- All logs to be TSV formatted (using Text::CSV to ensure correct writing)
