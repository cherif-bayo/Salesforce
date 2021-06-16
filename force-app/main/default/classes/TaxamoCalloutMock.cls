@isTest
global class TaxamoCalloutMock implements HttpCalloutMock {
	OrderItem oi;
	QuoteLineItem qi;

	global TaxamoCalloutMock(OrderItem oi) {
		this.oi = oi;
	}

	global TaxamoCalloutMock(QuoteLineItem qi) {
		this.qi = qi;
	}

	global HttpResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setStatus('OK');
		res.setStatusCode(200);

		String body = '{                                                                        '
		+ '    "is_delegated": false,'
		+ '    "transaction": {'
		+ '        "amount": 100.0,'
		+ '        "invoice_address": {'
		+ '            "building_number": "5",'
		+ '            "street_name": "rue de preignac",'
		+ '            "city": "Fort de France",'
		+ '            "postal_code": "97200",'
		+ '            "country": "MQ"'
		+ '        },'
		+ '        "tax_country_codes": "MQ",'
		+ '        "tax_amount": 0,'
		+ '        "tax_deducted": false,'
		+ '        "tax_region": "GP",'
		+ '        "billing_country_code": "MQ",'
		+ '        "evidence": {'
		+ '            "by_billing": {'
		+ '                "evidence_value": "MQ",'
		+ '                "used": true,'
		+ '                "resolved_country_code": "MQ",'
		+ '                "evidence_type": "by-billing"'
		+ '            }'
		+ '        },'
		+ '        "tax_country_code": "MQ",'
		+ '        "countries": {'
		+ '            "by_billing": {'
		+ '                "code_long": "MTQ",'
		+ '                "name": "Martinique",'
		+ '                "cca2": "MQ",'
		+ '                "tax_region": "GP",'
		+ '                "codenum": "474",'
		+ '                "currency": ['
		+ '                    "EUR"'
		+ '                ],'
		+ '                "code": "MQ",'
		+ '                "cca3": "MTQ",'
		+ '                "callingCode": ['
		+ '                    "596"'
		+ '                ],'
		+ '                "tax_supported": true,'
		+ '                "ccn3": "474"'
		+ '            },'
		+ '            "detected": {'
		+ '                "code_long": "MTQ",'
		+ '                "name": "Martinique",'
		+ '                "cca2": "MQ",'
		+ '                "tax_region": "GP",'
		+ '                "codenum": "474",'
		+ '                "currency": ['
		+ '                    "EUR"'
		+ '                ],'
		+ '                "code": "MQ",'
		+ '                "cca3": "MTQ",'
		+ '                "callingCode": ['
		+ '                    "596"'
		+ '                ],'
		+ '                "tax_supported": true,'
		+ '                "ccn3": "474"'
		+ '            }'
		+ '        },'
		+ '        "transaction_lines": ['
		+ '            {'
		+ '                "description": "Solution simple",'
		+ '                "amount": 100.0,'
		+ '                "unit_price": 10,'
		+ '                "tax_deducted": false,'
		+ '                "tax_region": "GP",'
		+ '                "product_code": "BASIC",'
		+ '                "tax_country_code": "MQ",'
		+ '                "line_key": "Q2hZV9Y0d3dKu8h2",'
		+ '                "custom_id": "XXX",'
		+ '                "product_type": "software-download",'
		+ '                "line_num": 1,'
		+ '                "deducted_tax_amount": 0,'
		+ '                "quantity": 10,'
		+ '                "total_amount": 100.0,'
		+ '                "deducted_tax_rate": 0,'
		+ '                "tax_supported": false'
		+ '            }'
		+ '        ],'
		+ '        "refunded_tax_amount": 0,'
		+ '        "force_country_code": null,'
		+ '        "country_name": "Martinique",'
		+ '        "product_classes": "D",'
		+ '        "fully_informative": false,'
		+ '        "kind": "untaxed",'
		+ '        "refunded_total_amount": 0,'
		+ '        "order_date_type": "timestamp",'
		+ '        "shipment_country_data": {},'
		+ '        "deducted_tax_amount": 0,'
		+ '        "order_date": "2019-11-04T16:20:26Z",'
		+ '        "total_amount": 100.0,'
		+ '        "tax_timezone": "GMT",'
		+ '        "sub_account_id": "18147",'
		+ '        "tax_supported": false,'
		+ '        "currency_code": "EUR"'
		+ '    },'
		+ '    "tax_required_fields": [],'
		+ '    "storage_required_fields": []          '
		+ '}';

		if (oi != null) res.setBody(body.replaceAll('XXX', oi.OrderItemNumber));
		else if (qi != null) res.setBody(body.replaceAll('XXX', qi.LineNumber));
		else res.setBody(body);

		return res;
	}
}