component output=false {

	property name="assetManagerService" inject="assetManagerService";

	public function asset( event, rc, prc ) output=false {
		var assetId         = rc.assetId      ?: "";
		var derivativeName  = rc.derivativeId ?: "";
		var asset           = "";

		if ( Len( Trim( derivativeName ) ) ) {
			asset = assetManagerService.getAssetDerivative( assetId=assetId, derivativeName=derivativeName );
		} else {
			asset = assetManagerService.getAsset( id=assetId );
		}

		// still todo, permissioning

		if ( asset.recordCount ) {
			var assetBinary = "";
			var type        = assetManagerService.getAssetType( name=asset.asset_type, throwOnMissing=true );

			if ( Len( Trim( derivativeName ) ) ) {
				assetBinary = assetManagerService.getAssetDerivativeBinary( assetId=assetId, derivativeName=derivativeName );
			} else {
				assetBinary = assetManagerService.getAssetBinary( id=assetId );
			}

			if ( type.serveAsAttachment ) {
				header name="Content-Disposition" value="attachment; filename=#asset.label#.#type.extension#";
			}

			content
				reset    = true
				variable = assetBinary
				type     = type.mimeType;
			abort;
		}


		event.renderData( data="not found", type="text", statusCode=404 );
	}

	public function tempFile( event, rc, prc ) output=false {
		var tmpId           = rc.assetId ?: "";
		var fileDetails     = assetManagerService.getTemporaryFileDetails( tmpId );
		var fileTypeDetails = "";

		if ( StructCount( fileDetails ) ) {
			fileTypeDetails = assetManagerService.getAssetType( filename=filedetails.name );

			if ( ( fileTypeDetails.groupName ?: "" ) eq "image" ) {
				// brutal for now - no thumbnail generation, just spit out the file
				content reset=true variable="#assetManagerService.getTemporaryFileBinary( tmpId )#" type="#fileTypeDetails.mimeType#";abort;
			} else {
				var iconFile = event.getSystemAssetsPath() & "/images/asset-type-icons/48px/#ListLast( fileDetails.name, "." )#.png";
				content reset=true file="#iconFile#" deleteFile=false type="image/png";abort;
			}
		}

		event.renderData( data="not found", type="text", statusCode=404 );
	}

}