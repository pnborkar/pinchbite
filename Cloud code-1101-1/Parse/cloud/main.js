var Stripe = require('stripe');

// Replace this with your Stripe secret key, found at https://dashboard.stripe.com/account/apikeys
var stripe_secret_key = "sk_test_qWC8dbde7K9vQDAjNEOUXjyC";
var listdata = [];

Stripe.initialize(stripe_secret_key);

Parse.Cloud.define("charge", function(request, response) {
  Stripe.Charges.create({
    amount: request.params.amount, // in cents
    currency: request.params.currency,
    card: request.params.token
  },{
    success: function(httpResponse) {
      response.success("Card charge successfull!");
    },
    error: function(httpResponse) {
      response.error("Hmm! Check the card!");
    }
  });
});


Parse.Cloud.define("createcustomer", function(request, response) {
                   Stripe.Customers.create({
                                         card: request.params.token, // in cents
                                         description: request.params.description,
                                         email: request.params.email,
                                         id: request.params.id
                                         },{
                                         success: function(httpResponse) {
                                         response.success("Customer created!");
                                         },
                                         error: function(httpResponse) {
                                        response.error("Hmm!, Something went wrong while creating");
                                      }
                                  });
});

Parse.Cloud.define("updatecustomer", function(request, response) {
                   Stripe.Customers.update(request.params.id, {
                                           card: request.params.token // in cents
                                           },{
                                           success: function(httpResponse) {
                                           response.success("Customer data updated!");
                                           },
                                           error: function(httpResponse) {
                                           response.error("Hmm!, Something went wrong while updating");
                                           }
                                           });
                   });



Parse.Cloud.define("chargecustomer", function(request, response) {
                   Stripe.Charges.create({
                                         amount: request.params.amount, // in cents
                                         currency: request.params.currency,
                                         customer: request.params.customer
                                         },{
                                         success: function(httpResponse) {
                                         response.success("Card charge successfull!");
                                         },
                                         error: function(httpResponse) {
                                         response.error("Hmm! Check the card!");
                                         }
                                         });
                   });


Parse.Cloud.define("deletecardforcustomer", function(request, response) {
                   Parse.Cloud.httpRequest({
                                           url: "https://" + stripe_secret_key  +":@api.stripe.com/v1/customers/" + request.params.customer + "/cards",
                                           success: function(httpResponse) {
                                           response.success(httpResponse.data);
                                           listdata = JSON.stringify(httpResponse.data);
                                           var parseddata = JSON.parse(listdata);
                                           var cardid = parseddata.data[0].id;
                                           if ( cardid != null) {
                                                console.log ("\nGot the card id :: " + cardid);
                                                Parse.Cloud.httpRequest({
                                                                   method: 'DELETE',
                                                                   url: "https://" + stripe_secret_key  +":@api.stripe.com/v1/customers/" + request.params.customer + "/cards/" + cardid,
                                                                   success: function(httpResponse) {
                                                                   response.success(httpResponse.text);
                                                                   },
                                                                   error: function(httpResponse) {
                                                                   response.error('Request failed with response code ' + httpResponse.status);
                                                                   }
                                                        });
                                           }
                                           
                                           },
                                           error: function(httpResponse) {
                                           response.error('Request failed with response code ' + httpResponse.status);
                                           }
                                           });
                   });

