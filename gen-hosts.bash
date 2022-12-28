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
)

for i in $(seq 0 100); do
    # echo "Adding region $i of app-measurement.com" > /dev/stderr
    BLOCK+=("region$i.app-measurement.com")
done

for domain in "${BLOCK[@]}"; do
    echo "0.0.0.0 $domain"
done

echo
echo '# End of custom hosts file'
echo '# If you can see this in your console, you need to export this output to a file.'
exit 0
