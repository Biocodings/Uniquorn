% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Create_BED_files.R
\name{create_bed_file}
\alias{create_bed_file}
\title{create_bed_file}
\usage{
create_bed_file(

sim_list,

vcf_fingerprint,

res_table,

output_file,

ref_gen,

manual_identifier

)
}
\arguments{
\item{sim_list}{R table which contains the mutations from the training database for the cancer cell lines}

\item{vcf_fingerprint}{contains the mutations that are present in the query cancer cell line's vcf file}

\item{res_table}{Table containing the identification results}

\item{output_file}{Path to output file}

\item{ref_gen}{Reference genome version}

\item{manual_identifier}{Manually enter a vector of CL name(s) whose bed files should be created, independently from them passing the detection threshold}
}
\value{
Returns a message which indicates if the BED file creation has succeeded
}
\description{
Creates BED files from the found and not found annotated mutations
}

