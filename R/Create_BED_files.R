#' create_bed_file
#' 
#' Creates BED files from the found and not found annotated mutations
#' 
#' @param sim_list R table which contains the mutations from the training database for the cancer cell lines
#' @param vcf_fingerprint contains the mutations that are present in the query cancer cell line's vcf file
#' @param res_table Table containing the identification results
#' @param output_file Path to output file
#' @param ref_gen Reference genome version
#' @param manual_identifier Manually enter a vector of CL name(s) whose bed files should be created, independently from them passing the detection threshold
#' @return Returns a message which indicates if the BED file creation has succeeded
#' @usage 
#' create_bed_file(
#' 
#' sim_list,
#' 
#' vcf_fingerprint,
#' 
#' res_table,
#' 
#' output_file,
#' 
#' ref_gen,
#' 
#' manual_identifier
#' 
#' )
create_bed_file = function( sim_list, vcf_fingerprint, res_table, output_file, ref_gen, manual_identifier ){
 
    # prep

    # start
    
    print("Creating bed files")
    
    found_res_tab = res_table[ as.logical( res_table$Passed_threshold ), ]
    found_identifier = paste( found_res_tab$CL, found_res_tab$CL_source, sep = "_")
    
    found_identifier = unique( c( manual_identifier, found_identifier ) )
    
    for ( identifier in found_identifier ){
        
        if ( identifier != "" ){
        
            print(identifier)
            
            name_training_bed_file = stringr::str_replace( output_file, "_uniquorn_ident.tab", paste0( c( "_uniquorn_ident_mutations_training_set_",identifier,".bed"), collapse = "" ) )
            name_query_bed_file    = stringr::str_replace( output_file, "_uniquorn_ident.tab", paste0( c( "_uniquorn_ident_mutations_query_set_",identifier,".bed"), collapse = ""  ) ) 
            name_missed_bed_file   = stringr::str_replace( output_file, "_uniquorn_ident.tab", paste0( c( "_uniquorn_ident_mutations_missed_set_",identifier,".bed"), collapse = ""  ) )
            
            # training
            
            training_bed_file = paste0( 
                c( 
                    'track name=',
                    'Training_',
                    identifier,
                    ' description=Trainingset_mutations type=bedDetail db=',
                    ref_gen,
                    ' color=0,0,255 priority=3'
                ),
                collapse = ""
            )
            
            training_coords = sim_list$Fingerprint[ sim_list$CL == identifier ]
            training_coords = stringr::str_trim( training_coords )
            training_coords = training_coords[ ! grepl("^[c(']", training_coords ) ]
            training_coords = stringr::str_split( training_coords, "_" )
            
            training_coords_res = sapply( training_coords, FUN = function( vec ){ 
                chrom = paste( "chr", stringr::str_trim( vec[1] ), sep = "" )
                return( paste0( c( chrom, as.character( as.integer( vec[2] ) ), as.integer( as.integer( vec[3] ) ) ), collapse = "\t" ) )
            } )
            training_coords_res = c( training_bed_file, training_coords_res )
            
            utils::write.table( x = training_coords_res, file =  name_training_bed_file, sep ="", row.names = FALSE, col.names = FALSE, quote = FALSE )
    
            # query
            
            query_bed_file = paste0( 
                c( 
                    'track name=',
                    'Query_',
                    identifier,
                    ' description=Query_mutations type=bedDetail db=',
                    ref_gen,
                    ' color=0,255,0 priority=3'
                ),
                collapse = ""
            )
            
            query_coords = vcf_fingerprint
            query_coords = stringr::str_trim( query_coords )
            query_coords = query_coords[ ! grepl("^[c(']", query_coords ) ]
            query_coords = stringr::str_split( query_coords, "_" )
            
            query_coords_res = sapply( query_coords, FUN = function( vec ){ 
                chrom = paste( "chr", stringr::str_trim( vec[1] ), sep = "" )
                return( paste0( c( chrom, as.character( as.integer( vec[2] ) ), as.integer( as.integer( vec[3] ) ) ), collapse = "\t" ) )
            } )
            query_res = c( query_bed_file, query_coords_res )
            
            utils::write.table( x = query_res, file =  name_query_bed_file, sep ="", row.names = FALSE, col.names = FALSE, quote = FALSE )        
                    
            # missed
            
            missed_bed_file = paste0( 
                c( 
                    'track name=',
                    'Missed_',
                    identifier,
                    ' description=Missed_trainingset_mutations type=bedDetail db=',
                    ref_gen,
                    ' color=255,0,0 priority=3'
                ),
                collapse = ""
            )
            
            missed_coords = training_coords[ which( ! ( training_coords %in% query_coords ) ) ]
            
            missed_coords = sapply( missed_coords, FUN = function( vec ){ 
                chrom = paste( "chr", stringr::str_trim( vec[1] ), sep = "" )
                return( paste0( c( chrom, as.character( as.integer( vec[2] ) ), as.integer( as.integer( vec[3] ) ) ), collapse = "\t" ) )
            } )
            missed_coords_res = c( missed_bed_file, missed_coords )
            
            utils::write.table( x = missed_coords_res, file =  name_missed_bed_file, sep ="", row.names = FALSE, col.names = FALSE, quote = FALSE )
        }
    }
}