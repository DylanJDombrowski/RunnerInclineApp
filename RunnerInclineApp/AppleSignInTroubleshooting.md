# Apple Sign In Configuration Troubleshooting

## ✅ Configuration Checklist

### Apple Developer Console
- [ ] App ID created with "Sign In with Apple" enabled
- [ ] Services ID created (e.g., `com.yourname.RunnerInclineApp.service`)
- [ ] Services ID has "Sign In with Apple" enabled
- [ ] Web Authentication configured with:
  - [ ] Domains: `YOUR-PROJECT-REF.supabase.co`
  - [ ] Return URLs: `https://YOUR-PROJECT-REF.supabase.co/auth/v1/callback`
- [ ] Private Key (.p8) created with "Sign In with Apple" enabled

### Supabase Configuration
- [ ] Apple provider enabled in Authentication → Providers
- [ ] Client ID set to Services ID (not App ID!)
- [ ] Client Secret (JWT) generated and added
- [ ] Redirect URL: `https://YOUR-PROJECT-REF.supabase.co/auth/v1/callback`

## 🔧 Common Issues

### Issue: "Invalid client_id"
**Fix**: Make sure Client ID in Supabase is your **Services ID**, not your App ID
- ❌ Wrong: `com.yourname.RunnerInclineApp`
- ✅ Correct: `com.yourname.RunnerInclineApp.service`

### Issue: "Invalid client_secret" 
**Fix**: JWT token expired or malformed
- Generate new JWT with current timestamp
- Make sure Team ID, Key ID, and Services ID are correct in JWT payload

### Issue: "Redirect URI mismatch"
**Fix**: URLs must match exactly
- Supabase: `https://YOUR-PROJECT-REF.supabase.co/auth/v1/callback`
- Apple: Same exact URL in Services ID configuration

### Issue: "Unknown error"
**Fix**: Usually a configuration propagation delay
- Wait 10-15 minutes after making changes
- Clear browser cache if testing on web

## 📋 Quick Fixes to Try

1. **Double-check Client ID**: Should be Services ID, not App ID
2. **Regenerate JWT Client Secret**: Use current timestamp
3. **Verify redirect URL**: Must match exactly between Apple and Supabase
4. **Wait for propagation**: Changes can take 10-15 minutes
5. **Check Supabase logs**: Will show exact error message