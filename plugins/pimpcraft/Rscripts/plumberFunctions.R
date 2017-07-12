#http://localhost:32908/pathmap?biosource=1363&compartment=mitochondrion

#* @get /pathmap
function(biosource, compartment = NA){
  bioSource <- biosource
  compartmentWanted <- compartment
  source("autoPathMap-simplegrid.R", local = TRUE)
  return(mapOut)
}
