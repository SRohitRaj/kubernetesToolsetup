
variable "zone_id" {
  description = ""
  type = string 
  default = "Z096624234XGIJ6JVLJT8"
}
variable "type" {
  description = ""
  type = string 
  default = "CNAME"
}
variable "records" {
  description = ""
  type = list
  default = ["bangiteaserverdevopstk.record"]
}
variable "name" {
  description = ""
  type = string 
  default = "ban"
}
variable "ttl" {
  description = ""
  type = string 
  default = "400"
}
