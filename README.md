# ENA Mirror Processor

## Install dependencies

This is a pure perl library. All dependencies are handled in a cpanfile and using cpanm.

```
cpanm --installdeps .
```

If you have the excellent [carton](https://metacpan.org/pod/Carton) library available you can use this to manage your dependencies.

```
carton install
perl -I ./local/lib/perl5/ ./bin/load_expanded_con.pl -h
```

## Load expanded cons

```
./bin/load_expanded_con.pl --store-path where/you/will/store/things --file-path EMBL.file.dat.gz --process-id anything
```

The above program will

- Open the given EMBL expanded con file, download them from ftp://ftp.ebi.ac.uk/pub/databases/ena/sequence/release/expanded_con
- Parse them using the `Bio::Perl` embl parser
- Extract the sequence, calculate checksums and metadata
- Write these to disk under a `seq`, `json` and `logs` path under the given `--store-path`
- Logs are written with the `--process-id` (see below for the types of logs)

# Generated Logs

To keep a handle on processing, this code produces a number of logs to disk. See below for the various types of log generated. All files are uncompressed CSVs with headers.

## Metadata log

Populated with all pertinent metadata from a load. Columns are:

- timestamp
- trunc512 checksum
- md5 checksum
- sequence length
- sha512 checksum
- base64 url encoded version of trunc512
- versioned accession
- record type e.g. expanded_con

## Loader log

Records as/when a record was processed with a success boolean and a path. Columns are:

- timestamp
- loading completed (boolean but set to 1 or 0)
- trunc512 checksum
- md5 checksum
- path to sequence

## Version log

Logs if there is further processing required on a record because the version was greater than 1. Columns are:

- timestamp
- accession
- current version
