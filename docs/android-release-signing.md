# Android Release Signing

Release variants must use a maintainer-controlled upload/release keystore. The
repository intentionally contains no signing key or password, and Android
release packaging fails unless all signing properties are supplied.

Create `app/android/key.properties` locally (it is ignored by Git):

```properties
storeFile=/secure/path/timeflow-upload-key.jks
storePassword=<secret>
keyAlias=<alias>
keyPassword=<secret>
```

Back up the keystore and credentials separately in a secure password manager.
Never commit them or include them in an issue, pull request, build log, or
artifact. CI debug builds do not need release credentials. Production signing,
Play Console enrollment, upload-key custody, and signed AAB verification remain
release-owner gates; this Linux environment has no Apple signing environment for
iOS distribution.
