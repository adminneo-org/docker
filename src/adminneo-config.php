<?php

$variables = [
	"theme" => "NEO_THEME",
	"colorVariant" => "NEO_COLOR_VARIANT",
	"cssUrls" => "NEO_CSS_URLS",
	"jsUrls" => "NEO_JS_URLS",
	"navigationMode" => "NEO_NAVIGATION_MODE",
	"preferSelection" => "NEO_PREFER_SELECTION",
	"jsonValuesDetection" => "NEO_JSON_VALUES_DETECTION",
	"jsonValuesAutoFormat" => "NEO_JSON_VALUES_AUTO_FORMAT",
	"enumAsSelectThreshold" => "NEO_ENUM_AS_SELECT_THRESHOLD",
	"recordsPerPage" => "NEO_RECORDS_PER_PAGE",
	"versionVerification" => "NEO_VERSION_VERIFICATION",
	"hiddenDatabases" => "NEO_HIDDEN_DATABASES",
	"hiddenSchemas" => "NEO_HIDDEN_SCHEMAS",
	"visibleCollations" => "NEO_VISIBLE_COLLATIONS",
	"defaultDriver" => "NEO_DEFAULT_DRIVER",
	"defaultPasswordHash" => "NEO_DEFAULT_PASSWORD_HASH",
	"sslKey" => "NEO_SSL_KEY",
	"sslCertificate" => "NEO_SSL_CERTIFICATE",
	"sslCaCertificate" => "NEO_SSL_CA_CERTIFICATE",
	"sslTrustServerCertificate" => "NEO_SSL_TRUST_SERVER_CERTIFICATE",
	"sslMode" => "NEO_SSL_MODE",
	"sslEncrypt" => "NEO_SSL_ENCRYPT",
];

$config = [];
foreach ($variables as $option => $variable) {
	$value = getenv($variable);

	if ($value === false) {
		continue;
	} elseif ($value == "null") {
		$value = null;
	} elseif ($value == "true") {
		$value = true;
	} elseif ($value == "false") {
		$value = false;
	} elseif (is_numeric($value)) {
		$value = (int)$value;
	}

	$config[$option] = $value;
}

return $config;
