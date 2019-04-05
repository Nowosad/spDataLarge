#' Polish election data 2015
#' 
#' Polish Presidential election 2015 data by gminy and Warsaw borough areal units
#' 
#' @format \code{sf} data frame object with 2495 areal units and 65 variables
#' \itemize{
#'  \item{\code{TERYT}, \code{TERYT0}, \code{gm0}}{TERYT areal unit IDs}
#'  \item{\code{name0}}{original areal unit names}
#'  \item{\code{name}}{cleaned areal unit names}
#'  \item{\code{types}}{factor with levels \dQuote{Rural}, \dQuote{Urban}, \dQuote{Urban/rural} and \dQuote{Warsaw borough}}
#'  \item{\code{I_turnout}}{First round turnout proportion}
#'  \item{\code{II_turnout}}{Runoff round turnout proportion}
#'  \item{\code{I_Duda_share}}{Winner first round share}
#'  \item{\code{II_Duda_share}}{Winner runoff round share}
#'  \item{\code{I_Komorowski_share}}{Incumbent first round share}
#'  \item{\code{II_Komorowski_share}}{Incumbent runoff round share}
#'  \item{\code{I_*}}{First round aggregated counts of all polling station data}
#'  \item{\code{II_*}}{Runoff round aggregated counts of all polling station data}
#' }
#' 
#' @note \dQuote{PVE} in variable names means \dQuote{postal voting envelopes}; voters requesting a postal voting package are expected to return a postal voting envelope with a declaration, and a sealed voting envelope to be placed in the ballot box.
#' 
#' @source \url{https://prezydent2015.pkw.gov.pl/319_Pierwsze_glosowanie}, \url{https://prezydent2015.pkw.gov.pl/325_Ponowne_glosowanie}, \url{http://www.codgik.gov.pl/index.php/darmowe-dane/prg.html}
#' 
#' @author Roger Bivand
#' 
#' @aliases pol_pres15
#' 
#' @examples \dontrun{
#' data("pol_pres15", package="spDataLarge")
#' wd <- aggregate(pol_pres15$I_entitled_to_vote, list(pol_pres15$types), sum)$x
#' boxplot(I_turnout ~ types, data=pol_pres15, width=wd)
#' }
"pol_pres15"
