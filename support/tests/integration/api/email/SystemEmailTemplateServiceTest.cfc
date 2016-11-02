component extends="resources.HelperObjects.PresideBddTestCase" {

	function run() {

		describe( "listTemplates()", function(){
			it( "should return an array of templates based on system email templates config (settings.email.templates) decorated with title and description and sorted by title", function(){
				var service   = _getService();
				var templates = _getDefaultConfiguredTemplates().keyArray();
				var expected  = [];

				for( var templateId in templates ) {
					var template = {
						  id          = templateId
						, title       = "Template #templateId#"
						, description = "This is the template: #templateId#"
					};

					service.$( "$translateResource" ).$args( uri="email.template.#templateId#:title"      , defaultValue=templateId ).$results( template.title );
					service.$( "$translateResource" ).$args( uri="email.template.#templateId#:description", defaultValue=""         ).$results( template.description );

					expected.append( template );
				}

				expected.sort( function( a, b ){
					return a.title > b.title ? 1 : -1;
				} );

				expect( service.listTemplates() ).toBe( expected );
			} );
		} );

		describe( "listTemplateParameters()", function(){
			it( "should return configured parameters for the given template with translated titles and descriptions", function(){
				var service  = _getService();
				var template = "adminResetPassword"
				var expected = [{
					  id          = "resetLink"
					, title       = "Reset link"
					, description = "Blah blah blah test"
					, required    = true
				},{
					  id          = "testParam"
					, title       = "Test param"
					, description = "Blah blah blah test"
					, required    = false
				}];

				for( var param in expected ) {
					service.$( "$translateResource" ).$args( uri="email.template.#template#:param.#param.id#.title"      , defaultValue=param.id ).$results( param.title );
					service.$( "$translateResource" ).$args( uri="email.template.#template#:param.#param.id#.description", defaultValue=""       ).$results( param.description );
				}

				expect( service.listTemplateParameters( template ) ).toBe( expected );
			} );

			it( "should return an empty array when the template does not have any defined parameters", function(){
				expect( _getService().listTemplateParameters( "adminWelcome" )  ).toBe( [] );
			} );

			it( "should return an empty array when the template does not exist", function(){
				expect( _getService().listTemplateParameters( CreateUUId() )  ).toBe( [] );
			} );
		} );

		describe( "templateExists()", function(){
			it( "should return true if the provided template is configured in the system", function(){
				expect( _getService().templateExists( "websiteResetPassword" ) ).toBe( true );
			} );

			it( "should return false if the provided template is not configured in the system", function(){
				expect( _getService().templateExists( CreateUUId() ) ).toBe( false );
			} );
		} );

		describe( "prepareParameters()", function(){
			it( "should call the 'prepareParameters' method on the corresponding handler for the given template, passing any args through to the method, and return the result", function(){
				var service    = _getService();
				var template   = "adminWelcome"
				var args       = { moreTesting = CreateUUId() };
				var mockResult = { test=CreateUUId() };

				mockColdboxController.$( "handlerExists" ).$args( "email.template.#template#.prepareParameters" ).$results( true );
				mockColdboxController.$( "runEvent" ).$args(
					  event          = "email.template.#template#.prepareParameters"
					, eventArguments = args
					, private        = true
					, prePostExempt  = true
				).$results( mockResult );

				expect( service.prepareParameters(
					  template = template
					, args     = args
				) ).toBe( mockResult );
			} );

			it( "should return an empty struct when the template does not exist", function(){
				expect( _getService().prepareParameters(
					  template = CreateUUId()
					, args     = {}
				) ).toBe( {} );
			} );

			it( "should return an empty struct when the template does not have a corresponding prepareParameters handler action", function(){
				var service    = _getService();
				var template   = "adminWelcome"
				var args       = { moreTesting = CreateUUId() };

				mockColdboxController.$( "handlerExists" ).$args( "email.template.#template#.prepareParameters" ).$results( false );

				expect( service.prepareParameters(
					  template = template
					, args     = args
				) ).toBe( {} );
			} );
		} );

		describe( "prepareAttachments()", function(){
			it( "should call the 'prepareAttachments' method on the corresponding handler for the given template, passing any args through to the method, and return the result", function(){
				var service    = _getService();
				var template   = "adminWelcome"
				var args       = { moreTesting = CreateUUId() };
				var mockResult = [{ name="test", location="/path/to/file.jpg" }];

				mockColdboxController.$( "handlerExists" ).$args( "email.template.#template#.prepareAttachments" ).$results( true );
				mockColdboxController.$( "runEvent" ).$args(
					  event          = "email.template.#template#.prepareAttachments"
					, eventArguments = args
					, private        = true
					, prePostExempt  = true
				).$results( mockResult );

				expect( service.prepareAttachments(
					  template = template
					, args     = args
				) ).toBe( mockResult );
			} );

			it( "should return an empty array when the template does not exist", function(){
				expect( _getService().prepareAttachments(
					  template = CreateUUId()
					, args     = {}
				) ).toBe( [] );
			} );

			it( "should return an empty array when the template does not have a corresponding prepareAttachments handler action", function(){
				var service    = _getService();
				var template   = "adminWelcome"
				var args       = { moreTesting = CreateUUId() };

				mockColdboxController.$( "handlerExists" ).$args( "email.template.#template#.prepareAttachments" ).$results( false );

				expect( service.prepareAttachments(
					  template = template
					, args     = args
				) ).toBe( [] );
			} );
		} );

		describe( "getDefaultSubject()", function(){
			it( "should return result of calling 'email.template.{templateid}.defaultSubject' viewlet", function(){
				var service    = _getService();
				var template   = "websiteWelcome";
				var mockResult = CreateUUId();

				mockColdboxController.$( "viewletexists" ).$args( "email.template.#template#.defaultSubject" ).$results( true );
				service.$( "$renderViewlet" ).$args( "email.template.#template#.defaultSubject" ).$results( mockResult );

				expect( service.getDefaultSubject( template ) ).toBe( mockResult );
			} );

			it( "should return templateid, if no viewlet exists", function(){
				var service  = _getService();
				var template = "websiteWelcome";

				mockColdboxController.$( "viewletexists" ).$args( "email.template.#template#.defaultSubject" ).$results( false );

				expect( service.getDefaultSubject( template ) ).toBe( template );
			} );

			it( "should return templateid, if the template does not exist", function(){
				var service  = _getService();
				var template = CreateUUId();

				expect( service.getDefaultSubject( template ) ).toBe( template );
			} );
		} );

		describe( "getDefaultHtmlBody()", function(){
			it( "should return result of calling 'email.template.{templateid}.defaultHtmlBody' viewlet", function(){
				var service    = _getService();
				var template   = "websiteWelcome";
				var mockResult = CreateUUId();

				mockColdboxController.$( "viewletexists" ).$args( "email.template.#template#.defaultHtmlBody" ).$results( true );
				service.$( "$renderViewlet" ).$args( "email.template.#template#.defaultHtmlBody" ).$results( mockResult );

				expect( service.getDefaultHtmlBody( template ) ).toBe( mockResult );
			} );

			it( "should return empty string, if no viewlet exists", function(){
				var service  = _getService();
				var template = "websiteWelcome";

				mockColdboxController.$( "viewletexists" ).$args( "email.template.#template#.defaultHtmlBody" ).$results( false );

				expect( service.getDefaultHtmlBody( template ) ).toBe( "" );
			} );

			it( "should return empty string, if the template does not exist", function(){
				var service  = _getService();
				var template = CreateUUId();

				expect( service.getDefaultHtmlBody( template ) ).toBe( "" );
			} );
		} );

		describe( "getDefaultTextBody()", function(){
			it( "should return result of calling 'email.template.{templateid}.defaultTextBody' viewlet", function(){
				var service    = _getService();
				var template   = "websiteWelcome";
				var mockResult = CreateUUId();

				mockColdboxController.$( "viewletexists" ).$args( "email.template.#template#.defaultTextBody" ).$results( true );
				service.$( "$renderViewlet" ).$args( "email.template.#template#.defaultTextBody" ).$results( mockResult );

				expect( service.getDefaultTextBody( template ) ).toBe( mockResult );
			} );

			it( "should return empty string, if no viewlet exists", function(){
				var service  = _getService();
				var template = "websiteWelcome";

				mockColdboxController.$( "viewletexists" ).$args( "email.template.#template#.defaultTextBody" ).$results( false );

				expect( service.getDefaultTextBody( template ) ).toBe( "" );
			} );

			it( "should return empty string, if the template does not exist", function(){
				var service  = _getService();
				var template = CreateUUId();

				expect( service.getDefaultTextBody( template ) ).toBe( "" );
			} );
		} );

	}

	private any function _getService( struct configuredTemplates=_getDefaultConfiguredTemplates() ){
		var service = createMock( object=new preside.system.services.email.SystemEmailTemplateService(
			configuredTemplates = arguments.configuredTemplates
		) );

		mockColdboxController = createStub();
		service.$( "$getColdbox", mockColdboxController );

		return service;
	}


	private struct function _getDefaultConfiguredTemplates() {
		return {
			  adminResetPassword   = { parameters=[ { id="resetLink", required=true }, "testParam" ] }
			, adminWelcome         = {}
			, websiteResetPassword = {}
			, websiteWelcome       = {}
		};
	}

}