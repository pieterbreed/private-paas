resource "aws_route53_zone" "top" {
  name = "${var.tld}"
}

resource "aws_route53_record" "top-ns" {
  zone_id = "${aws_route53_zone.top.zone_id}"
  name = "${var.tld}"
  type = "NS"
  ttl = "30"
  records = [
    "${aws_route53_zone.top.name_servers.0}",
    "${aws_route53_zone.top.name_servers.1}",
    "${aws_route53_zone.top.name_servers.2}",
    "${aws_route53_zone.top.name_servers.3}"
  ]
}

resource "aws_route53_record" "vault" {
  zone_id = "${aws_route53_zone.top.zone_id}"
  name = "vault.${var.tld}"
  type = "A"
  alias {
    name = "${aws_elb.fabio.dns_name}"
    zone_id = "${aws_elb.fabio.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "gateway" {
  zone_id = "${aws_route53_zone.top.zone_id}"
  name = "gw.${var.tld}"
  type = "A"
  alias {
    name = "${aws_elb.fabio.dns_name}"
    zone_id = "${aws_elb.fabio.zone_id}"
    evaluate_target_health = true
  }
}
