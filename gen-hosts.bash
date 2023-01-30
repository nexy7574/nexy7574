#!/usr/bin/env bash
echo '# PiHole custom hosts file'
echo '# Generated on' $(date) 'by gen-hosts.bash.'

BLOCK=(
    'adcolony.com'
    'adtilt.com'
    'applovin.com'
    'confection.io'
    'crashlytics.com'
    'amanotes.io'
    'supportmetrics.apple.com'
    'sentry.io'
    'datadoghq.com'
    'analytics.regex101.com'
    'analytics.servogram.io'
    'stats.redditmedia.com'
    'rpi-imager-stats.raspberrypi.com'
    'collect.analytics.unity3d.com'
    'analytics-ios.rayjump.com'
    'ecommerce.iap.unity3d.com'
    'api.mixpanel.com'
    'app-measurement.com'
    'firebaselogging-pa.googleapis.com'
    'confection-status.netlify.app'
    'copilot-telemetry.githubusercontent.com'
    'log.tailscale.io'
    'web-analytics.smile.io'
    'logging.je-apps.com'
    'logging-app.pe-prod.je-labs.com'
    'web-analytics.smile.io'
    'analytics.dots-services.com'
)

for file in ./hosts.d/*; do
    BLOCK+=("#")
    BLOCK+=("# $file")
    while IFS= read -r line
    do
        BLOCK+=("$line")
    done < "$file"
done

for domain in "${BLOCK[@]}"; do
    if [[ $domain == \#* ]]; then
        echo "$domain"
    else
        echo "0.0.0.0 $domain"
    fi
    
done

echo
echo '# End of custom hosts file'
echo '# If you can see this in your console, you need to export this output to a file.'
exit 0
