<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="webforms_Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login and Registration Sample</title>

    <!-- 
        CSS and JS references are kept external for simplicity. All custom JavaScript is written within the
        page below. This isn't a production practice that I would recommend, but it keeps things packaged well
        for a demo or proof-of-concept. In production, you may want to reference local CSS and JS, if that's 
        your practice. The custom JS code found within the page below should definitely be kept separate from
        the markup and called in as-needed for efficiency and reusability.

        The code below assumes you have some working knowledge of Knockout JS. If you don't and have questions
        around that framework - in or out of the context of this sample - please feel free to ask in Ektron's 
        developer forums (https://developer.ektron.com) or via the forum of your choice and tweet the link using
        the #EktronOH hashtag.
        -->

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.2.0/knockout-min.js" type="text/javascript"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/knockout-validation/1.0.2/knockout.validation.min.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row">
                <div class="col-xs-12">
                    <div class="page-header">
                        <h1>Login and Registration</h1>
                    </div>
                </div>
            </div>
        </div>

        <!--
            Using a Multiview for demo purposes in order to keep the demo as succinct as possible.

            In your own implementation, these may be a multiview, all AJAX, or separate pages or views.
            -->

        <asp:MultiView ID="uxLoginBox" runat="server">

            <!--
                The UserCredentials view is the initial and primary view of the page and contains the 
                User Registration as well as Login forms.

                Note that in this code sample, I did not employ any server-side validation. This should
                be added to your code before using this in your own solution.
                -->

            <asp:View ID="uxUserCredentials" runat="server">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-sm-6 col-md-4">

                            <!-- 
                                Below is the login form.

                                Because you can only have one Form in .NET WebForms, use asp:Panel controls 
                                to provide logical separation when you have multiple forms on the page. This
                                also allows you to set a default button, covering when the user presses
                                'Enter' to submit, for each 'form'.
                                -->

                            <asp:Panel ID="uxLoginForm" runat="server" DefaultButton="uxLogin" CssClass="panel panel-primary" Wrap="true">
                                <div class="panel-heading">Login</div>
                                <div class="panel-body" id="LoginForm">

                                    <!-- 
                                        I am using .NET form controls, so server-side validation would be easily added.

                                        However, my primary method of validation in this sample comes from Knockout Validation.
                                        https://github.com/Knockout-Contrib/Knockout-Validation

                                        After using it for this demo, I can highly recommend their code. Note the knockout bindings
                                        below.

                                        - *validationElement* is used to note where the error class should be applied. I'm applying it 
                                          to the form group so it covers the label plus input controls.

                                        - *value* is used on the textbox control so that when the control loses focus (or onblur), the
                                          knockout observable is updated with the newly entered value. You can change this to update the
                                          value as the user types by adding an additional binding for *valueUpdate*. More info can be 
                                          found here:
                                          http://knockoutjs.com/documentation/value-binding.html

                                        - *validationMessage* is applied to a span tag outside of the label and input fields. I'm using
                                          this to define precisely where and in what format any error messages will be shown. Knockout
                                          Validation has an option to automatically insert the error message after the input. I have 
                                          disabled that option in favor of greater control over the display.
                                        -->

                                    <div class="form-group" data-bind="validationElement: Username">
                                        <asp:Label AssociatedControlID="uxUsername" ID="uxUsernameLabel" runat="server" Text="Username" CssClass="control-label" />
                                        <asp:TextBox ID="uxUsername" runat="server" Placeholder="Username" CssClass="form-control" data-bind="value: Username"/>
                                        <span class="label label-danger" data-bind="validationMessage: Username"></span>
                                    </div>

                                    <!--
                                        Note that in the code below, I'm using a Bootstrap Input Group in order to add a show/hide option 
                                        to the password fields. This type of option is becoming more popular as a way to let the user 
                                        determine whether they want to see what they're typing (if they're at home, for example) or if 
                                        they want the password to remain hidden (sitting in a coffee shop).

                                        The validationMessage binding I mentioned above is used here to ensure that the message is placed
                                        after the input group. Otherwise, the auto-insert option would have attempted to insert the message
                                        in between the textbox and checkbox controls, thus breaking my UI.
                                        -->
                                    <div class="form-group" data-bind="validationElement: Password">
                                        <asp:Label AssociatedControlID="uxPassword" ID="uxPasswordLabel" runat="server" Text="Password" CssClass="control-label"/>
                                        <div class="input-group">
                                            <asp:TextBox ID="uxPassword" runat="server" TextMode="Password" CssClass="form-control" Placeholder="Password" data-bind="attr: { type: PasswordBoxMode }, value: Password" />
                                            <span class="input-group-addon">
                                                <input type="checkbox" id="loginsecurepass" class="secure-pass" data-bind="checked: SecurePasswords" checked /><label for="loginsecurepass">Hide</label>
                                            </span>
                                        </div>
                                        <span class="label label-danger" data-bind="validationMessage: Password"></span>
                                    </div>
                                    <div class="form-group">
                                        <!--
                                            I'm using the binding here to execute a function which will check the validation on 
                                            the form and prevent the form submission if validation fails.

                                            It's actually okay to use the click binding here precisely because I'm setting
                                            a default button option on the Panel above. When you hit 'Enter' within the Panel,
                                            Microsoft's JavaScript simulates a 'click' event on the desired button.
                                            -->
                                        <asp:Button ID="uxLogin" runat="server" Text="Login" OnClick="uxLogin_Click" CssClass="btn btn-primary" data-bind="click: ValidateLogin" />
                                    </div>
                                </div>
                            </asp:Panel>
                        </div>
                        <div class="col-sm-6 col-md-8">

                            <!-- An alert to show when registration is successful. -->
                            <div class="alert alert-success" id="uxRegSuccess" runat="server" visible="false">
                                <h2>Success!</h2>
                                <p>You may now login. Have your mobile phone handy so we can text you the code you'll need to login. Cheers!</p>
                            </div>

                            <!-- 
                                Below is the registration form.

                                Ektron requires a username, display name (I'm reusing the username for this), first name, 
                                last name, and password. I also am requiring an email address and phone number.

                                Many orgs use the email address as the login/username, which is fine. Just make sure you 
                                don't also set that as the display name or you'll risk exposing users' email addresses publicly.
                                -->
                            <asp:Panel ID="uxRegistrationForm" runat="server" DefaultButton="uxRegister" CssClass="panel panel-info">
                                <div class="panel-heading">Register</div>
                                <div class="panel-body" id="RegistrationForm">

                                    <!--
                                        It's easy to provide validation for passwords, email, etc. and neglect the poor username field.

                                        Here, I've applied one very custom bit of validation that should be applied to any Username or 
                                        Display Name field --- availability.

                                        Alert your users before they attempt to register if their desired name is unavailable. The best
                                        implementations of this also suggest additional usernames, often centered around fields the user
                                        has already entered. In this case, I'm only using their desired username as a base and appending
                                        suffixes to it. Obviously, if you're using email addresses as the username, you don't want to do 
                                        this. But you would want to do it for the user's selected alias/display name.

                                        For more detail around this, see the validation code below as well as the 
                                        ~/handlers/UsernameAvailability.ashx file included in this package.

                                        Other validation options applied to this and other fields are detailed in the Knockout code below.
                                        -->

                                    <div class="form-group" data-bind="validationElement: Username">
                                        <asp:Label AssociatedControlID="uxRegUsername" ID="uxRegUsernameLabel" runat="server" Text="Desired Username" CssClass="control-label" />
                                        <asp:TextBox ID="uxRegUsername" runat="server" CssClass="form-control" Placeholder="Username" data-bind="value: Username" />
                                        <span class="label label-info" data-bind="visible: ShowValidatingUsername">Validating username...</span>
                                        <span class="label label-danger" data-bind="validationMessage: Username"></span>
                                        <div class="alert alert-danger" style="padding-top:0.5em" data-bind="visible: ShowSuggestedNames">
                                            <p>You might try one of these...</p>
                                            <ul data-bind="foreach: SuggestedUsernames">
                                                <li data-bind="text: $data"></li>
                                            </ul>
                                        </div>
                                    </div>
                                    <div class="form-group" data-bind="validationElement: RegPassword">
                                        <asp:Label AssociatedControlID="uxRegPassword" ID="uxRegPasswordLabel" runat="server" Text="Password" CssClass="control-label" />
                                        <div class="input-group">
                                            <asp:TextBox ID="uxRegPassword" runat="server" TextMode="Password" CssClass="form-control" Placeholder="Password" data-bind="attr { type: PasswordBoxMode }, value: RegPassword" />

                                            <!--
                                                The show/hide password option here applies to both the Password and Confirm Password fields.
                                                -->
                                            <span class="input-group-addon">
                                                <input type="checkbox" id="registersecurepassa" class="secure-pass" data-bind="checked: SecurePasswords" checked /><label for="registersecurepassa">Hide</label>
                                            </span>
                                        </div>
                                        <div class="small">Password must be 6 characters or more and contain at least one upper, lower, and numeric character plus one or more of the following: <code>!@#$%^&*(){}[]=\/-+?.,<>~`'":;</code> or whitespace.</div>
                                        <span class="label label-danger" data-bind="validationMessage: RegPassword"></span>
                                    </div>
                                    <div class="form-group" data-bind="validationElement: RegPasswordConfirm">
                                        <asp:Label AssociatedControlID="uxRegPasswordConfirm" ID="uxRegPasswordConfirmLabel" runat="server" Text="Confirm Password" CssClass="control-label" />
                                        <asp:TextBox ID="uxRegPasswordConfirm" runat="server" TextMode="Password" CssClass="form-control" Placeholder="Password" data-bind="attr { type: PasswordBoxMode }, value: RegPasswordConfirm" />
                                        <span class="label label-danger" data-bind="validationMessage: RegPasswordConfirm"></span>
                                    </div>
                                    <div class="form-group" data-bind="validationElement: FirstName">
                                        <asp:Label AssociatedControlID="uxFirstName" ID="uxFirstNameLabel" runat="server" Text="First Name:" CssClass="control-label" />
                                        <asp:TextBox ID="uxFirstName" runat="server" TextMode="SingleLine" CssClass="form-control" Placeholder="John" data-bind="value: FirstName" />
                                        <span class="label label-danger" data-bind="validationMessage: FirstName"></span>
                                    </div>
                                    <div class="form-group" data-bind="validationElement: LastName">
                                        <asp:Label AssociatedControlID="uxLastName" ID="uxLastNameLabel" runat="server" Text="Last Name:" CssClass="control-label" />
                                        <asp:TextBox ID="uxLastName" runat="server" TextMode="SingleLine" CssClass="form-control" Placeholder="Carter" data-bind="value: LastName" />
                                        <span class="label label-danger" data-bind="validationMessage: LastName"></span>
                                    </div>
                                    <div class="form-group" data-bind="validationElement: Email">
                                        <asp:Label AssociatedControlID="uxRegEmail" ID="uxRegEmailLabel" runat="server" Text="Email" CssClass="control-label" />
                                        <asp:TextBox ID="uxRegEmail" runat="server" TextMode="Email" CssClass="form-control" Placeholder="john.carter@barsoom.mars" data-bind="value: Email" />
                                        <span class="label label-danger" data-bind="validationMessage: Email"></span>
                                    </div>
                                    <div class="form-group" data-bind="validationElement: Phone">
                                        <asp:Label AssociatedControlID="uxRegPhone" ID="uxRegPhoneLabel" runat="server" Text="SMS-Enabled Phone*" CssClass="control-label" />
                                        <asp:TextBox ID="uxRegPhone" runat="server" TextMode="Phone" CssClass="form-control" Placeholder="+1-212-555-1212" data-bind="value: Phone" />
                                        <div class="small">* Used for two-factor authentication. When you log in, we'll text you a 6-digit code to make sure it's <i>really</i> you.</div>
                                        <span class="label label-danger" data-bind="validationMessage: Phone"></span>
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="uxRegister" runat="server" Text="Register" OnClick="uxRegister_Click" CssClass="btn btn-primary" data-bind="click: ValidateRegistration" />
                                    </div>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
                <script type="text/javascript">
                    $(function () {

                        // The model for the registration form. Contains observables for all fields plus validation.
                        var RegistrationModel = function () {
                            var self = this;

                            // Container array for the usernames the UsernameAvailability handler will return
                            // if the desired username is taken.
                            self.SuggestedUsernames = ko.observableArray([]);

                            // Logic to show/hide the suggested names panel.
                            self.ShowSuggestedNames = ko.computed(function () {
                                return self.SuggestedUsernames().length > 0;
                            });

                            // Function that will be called by custom validation.
                            // If usernames are suggested, it will update the array.
                            // Otherwise it will set the array to empty.
                            self.IsUsernameValid = function (data) {
                                self.SuggestedUsernames(data.suggestedNames || []);
                            };

                            // Variable to set whether passwords entry should be obfuscated.
                            self.SecurePasswords = ko.observable(true);

                            // Username observable.
                            self.Username = ko.observable().extend({
                                // Self-explanatory. :)
                                required: true,
                                // Custom validation configured below.
                                availableName: self.IsUsernameValid,
                                // Regex validation that only allows whitelisted characters and has a custom error message defined.
                                pattern: {
                                    params: /^[a-zA-Z0-9\-\.\_]*$/,
                                    message: "Only alphanumeric characters and hyphens, periods, or underscores are allowed."
                                },
                                // Self-explanatory. :)
                                minLength: 4
                            });

                            // Sets whether the "Validating..." message should be shown. 
                            // This is set to true while the custom validation is making the AJAX call to 
                            // check whether the username is already in use.
                            self.ShowValidatingUsername = ko.observable(false);

                            // Use the 'subscribe' extension to monitor the status of the asynchronous validation.
                            // While it's validating, show the "Validating..." label. :)
                            self.Username.isValidating.subscribe(function (isValidating) {
                                if (isValidating) {
                                    self.ShowValidatingUsername(true);
                                } else {
                                    self.ShowValidatingUsername(false);
                                }
                            });

                            // Password validation.
                            // (max length is arbitrarily large - I tested and 50 works fine with Ektron).
                            self.RegPassword = ko.observable('').extend({
                                // Duh?
                                required: true,
                                // Rather than put min/max length into the Regex, I put them here.
                                // Regex only runs when it needs to.
                                minLength: 6,
                                maxLength: 50,
                                pattern: {
                                    // Admittedly, not the ugliest regular expression I've written.
                                    // I'm not proud.
                                    // It works.
                                    params: /^(?=.*[\d])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#\$%\^&\*\(\)\s\{\}\[\]\=\\\/\-\?\.\,\<\>\~\`\'\":;\+]).*$/,
                                    message: 'This does not meet minimum password requirements.'
                                }
                            });
                            // I don't really concern myself here with all of the validation
                            // above - if it matches what's above, and what's above is valid,
                            // then we're cool.
                            self.RegPasswordConfirm = ko.observable('').extend({
                                required: true,
                                // Custom validation configured below.
                                passwordMatch: self.RegPassword,
                            });

                            self.FirstName = ko.observable().extend({ required: true });
                            self.LastName = ko.observable().extend({ required: true });
                            self.Email = ko.observable().extend({ required: true, email: true });
                            self.Phone = ko.observable().extend({ required: true });

                            // Returns the appropriate attribute based on whether the user
                            // has determined to obfuscate password entry.
                            self.PasswordBoxMode = ko.computed(function () {
                                if (self.SecurePasswords()) {
                                    return "password";
                                } else {
                                    return "text";
                                }
                            });

                            // The observables within this model that will be validated.
                            var data = [
                                self.Username,
                                self.RegPassword,
                                self.RegPasswordConfirm,
                                self.Email,
                                self.Phone
                            ];

                            // Add validation group.
                            self.Errors = ko.validation.group(data);

                            // Function called when the Register button is clicked.
                            self.ValidateRegistration = function () {
                                // If there are no validation errors, proceed with registration.
                                if (self.Errors().length == 0) {
                                    return true;
                                } else {
                                    // Tells Knockout Validation to show all the error messages
                                    // in accordance with where I placed *validationMessage* bindings
                                    // within the markup.
                                    self.Errors.showAllMessages();
                                }
                            };
                        };

                        // The model for the login form - only two fields, so much easier. :)
                        var LoginModel = function () {
                            var self = this;

                            // Standard required field validation. If they get it wrong they get it wrong.
                            self.Username = ko.observable().extend({required: true});
                            self.Password = ko.observable().extend({ required: true });

                            // Observable which determines whether passwords are obfuscated in the input.
                            self.SecurePasswords = ko.observable(true);

                            // Same as above - returns the appropriate attribute value based on the user's
                            // desire to obfuscate password input.
                            self.PasswordBoxMode = ko.computed(function () {
                                if (self.SecurePasswords()) {
                                    return "password";
                                } else {
                                    return "text";
                                }
                            });

                            // The observables to be validated.
                            var data = [
                                self.Username,
                                self.Password
                            ];

                            // Add the validation group.
                            self.Errors = ko.validation.group(data);

                            // Same as above - check that the inputs are valid when Login is clicked.
                            self.ValidateLogin = function () {
                                if (self.Errors().length == 0) {
                                    return true;
                                } else {
                                    self.Errors.showAllMessages();
                                }
                            };
                        };

                        // Common configuration for validation across both forms.
                        ko.validation.configure({
                            // Let me determine where and how to output error messages.
                            insertMessages: false,
                            // Set the error class.
                            decorateElement: true,
                            // The error classes...
                            errorElementClass: 'has-error',
                            errorClass: 'has-error',
                            // Add the error message to the input element's "Title" attribute
                            errorsAsTitle: true,
                            // Set validation rules by input HTML5 type.
                            parseInputAttributes: true,
                            // Only trigger messages when the value is modified.
                            messagesOnModified: true,
                            // Trigger error classes when value is modified.
                            decorateElementOnModified: true,
                            // Do not assign error class directly to input element.
                            decorateInputElement: false
                        });


                        // Custom validation for confirm password field.
                        ko.validation.rules["passwordMatch"] = {
                            // The getValue method will retrieve the value from the observable.
                            // You can omit this if you're comparing the value to something more static.
                            // E.g. if you're passing 'true' for the 'otherVal' parameter, you don't
                            // need the getValue function.
                            // Here it's necessary because I'm comparing the entered value against another
                            // observable. So I need to execute the observable as a function to get the value.
                            getValue: function (o) {
                                return (typeof o === 'function' ? o() : o);
                            },
                            // Validator method should return true for valid, or false for invalid.
                            // val - the value of the observable being validated.
                            // otherVal - (optional) the value against which I want to compare the observable being validated.
                            // If the values are equal, then it passes validation.
                            validator: function (val, otherVal) {
                                return val === this.getValue(otherVal);
                            },
                            // Custom error message for this validator.
                            // Though this validator could be used for many different observables, they 
                            // would each get the same error message.
                            message: 'The passwords entered do not match.'
                        }

                        // Username Availability validation.
                        ko.validation.rules["availableName"] = {
                            // Let the Validation framework know that this is going to be making an asyncronous request
                            // so we can subscribe to it and also alert the visitor that things are going on behind the scenes.
                            async: true,
                            // The validator. In this case, the second parameter I'm passing is the callback
                            // I want to use to update the SuggestedNames list.
                            // The third parameter is basically an IsValid callback.
                            validator: function (val, func, callback) {
                                // Before going through the exercise of AJAX, make sure it's worth it.
                                if (val !== undefined && val.length > 0) {
                                    // Make the AJAX request.
                                    $.ajax({
                                        dataType: 'json',
                                        url: '/handlers/UsernameAvailability.ashx',
                                        // Pass the desired username (val)
                                        data: { u: val },
                                        success: function (data) {
                                            // Call my Suggested Names function
                                            func(data);
                                            // Use the callback to return true for valid or false for invalid.
                                            callback(data.nameIsAvailable);
                                        }
                                    });
                                }
                            },
                            // Custom message - see above.
                            message: 'Username entered is not available.'
                        }

                        // Register custom validation rules.
                        ko.validation.registerExtenders();

                        // Create login model.
                        var LoginInit = new LoginModel();
                        // Bind *only* to the Login Form. Without the second parameter, it will bind to the entire page.
                        // By binding it to a single element, I am able to have multiple models bound each to 
                        // different sections of the page.
                        ko.applyBindings(LoginInit, document.getElementById('LoginForm'));

                        // See above.
                        var RegistrationInit = new RegistrationModel();
                        ko.applyBindings(RegistrationInit, document.getElementById('RegistrationForm'));
                    });
                </script>
            </asp:View>
            <asp:View ID="uxDualFactorAuth" runat="server">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-sm-6 col-sm-offset-3">
                            <asp:Panel ID="uxDualFactorForm" runat="server" DefaultButton="uxVerify" CssClass="panel panel-primary">
                                <div class="panel-heading">Verify Your Identity</div>
                                <div class="panel-body" id="AuthCodeForm">
                                    <div class="form-group" data-bind="validationElement: AuthenticationCode">
                                        <asp:Label AssociatedControlID="uxAuthenticationCode" ID="uxAuthenticationCodeLabel" runat="server" Text="Authentication Code" CssClass="control-label" />
                                        <asp:TextBox ID="uxAuthenticationCode" runat="server" CssClass="form-control" Placeholder="123456" data-bind="value: AuthenticationCode" />
                                        <span class="label label-danger" data-bind="validationMessage: AuthenticationCode"></span>
                                        <asp:HiddenField ID="uxObjectReference" runat="server" />
                                    </div>
                                    <div class="form-group">
                                        <asp:Button ID="uxVerify" runat="server" Text="Verify" OnClick="uxVerify_Click" CssClass="btn btn-primary" data-bind="click: ValidateCode" />
                                    </div>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
                <script type="text/javascript">
                    $(function () {
                        var AuthCodeModel = function () {
                            var self = this;
                            self.AuthenticationCode = ko.observable().extend({
                                required: true,
                                digit: true,
                                minLength: 6,
                                maxLength: 6
                            });

                            var data = [
                                self.AuthenticationCode
                            ];

                            self.Errors = ko.validation.group(data);

                            self.ValidateCode = function () {
                                if (self.Errors().length == 0) {
                                    return true;
                                } else {
                                    self.Errors.showAllMessages();
                                }
                            };
                        };

                        ko.validation.configure({
                            insertMessages: false,
                            decorateElement: true,
                            errorElementClass: 'has-error',
                            errorClass: 'has-error',
                            errorsAsTitle: true,
                            parseInputAttributes: false,
                            messagesOnModified: true,
                            decorateElementOnModified: true,
                            decorateInputElement: false
                        });

                        // I don't have any, but if I want to add them, I'm prepared.
                        ko.validation.registerExtenders();

                        var ac = new AuthCodeModel();
                        ko.applyBindings(ac, document.getElementById('AuthCodeForm'));
                    });
                </script>
            </asp:View>
            <asp:View ID="uxLogout" runat="server">
                <div class="container-fluid">
                    <div class="row">
                        <div class="col-sm-6 col-sm-offset-3">
                            <div class="panel panel-primary">
                                <div class="panel-heading">You are Logged In</div>
                                <div class="panel-body">
                                    <p>
                                        You are logged in as <b><asp:Literal ID="uxLoggedInUsername" runat="server" /></b>
                                    </p>
                                    <p class="text-center">
                                        <asp:Button ID="Button1" runat="server" Text="Logout" OnClick="uxLogout_Click" CssClass="btn btn-primary" />
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:View>
        </asp:MultiView>
    </form>
</body>
</html>
