radosgw_cert_file:
  file.managed:
    - name: /usr/local/share/ca-certificates/radosgw.crt
    - user: root
    - group: root
    - mode: 644
    - contents: |
        -----BEGIN CERTIFICATE-----
        MIIEJzCCAw+gAwIBAgIJAPlYyAzoR6MkMA0GCSqGSIb3DQEBBQUAMGoxCzAJBgNV
        BAYTAlRXMQ8wDQYDVQQIEwZUYWl3YW4xDzANBgNVBAcTBlRhaXBlaTEUMBIGA1UE
        ChMLSG9wZWJheVRlY2gxETAPBgNVBAsTCEFya0ZsZXhVMRAwDgYDVQQDEwdyYWRv
        c2d3MB4XDTE2MDIwNDA3MTYwMFoXDTE3MDIwMzA3MTYwMFowajELMAkGA1UEBhMC
        VFcxDzANBgNVBAgTBlRhaXdhbjEPMA0GA1UEBxMGVGFpcGVpMRQwEgYDVQQKEwtI
        b3BlYmF5VGVjaDERMA8GA1UECxMIQXJrRmxleFUxEDAOBgNVBAMTB3JhZG9zZ3cw
        ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDzS6j04zaL5Dl5oHHqV6Tq
        +r7ORmajw6YUmetfG4mJlE3kPfk4KuO0NJi8UjxfKg6Uz9qIqe+0C0QWQ+vHZ4sa
        yqFXzVUr44Lg2sxlp7FBumNG7521ZSMslf1MC/cv6ayB9rc4RlNqQ62vBKLezRG2
        +UfE5aaH9plKsws0ru4tkfPdnxxfweaZSi8odKRsm43Qon5g3fu3Ovyv/3fFL9SD
        WJAqPm+KO1Yi4/Ik86ZXwpCjNmPrk8Qfx2fsHF9vZBROqw24Bw44shQYXaTtBYwG
        11sUcVY3zQc75ooCNW+m2/n+Uv2Sdtkzmc7qMUqX8+0NnJNL6fgjxubtSzQHxQXX
        AgMBAAGjgc8wgcwwHQYDVR0OBBYEFPOo2/VetIysiFgV+QnwnhquPGT0MIGcBgNV
        HSMEgZQwgZGAFPOo2/VetIysiFgV+QnwnhquPGT0oW6kbDBqMQswCQYDVQQGEwJU
        VzEPMA0GA1UECBMGVGFpd2FuMQ8wDQYDVQQHEwZUYWlwZWkxFDASBgNVBAoTC0hv
        cGViYXlUZWNoMREwDwYDVQQLEwhBcmtGbGV4VTEQMA4GA1UEAxMHcmFkb3Nnd4IJ
        APlYyAzoR6MkMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQEFBQADggEBAF/oxZTt
        PmkP8pXv6XkKmGfuML0/jCrsNGeY1Vd7l1zoF7IiVEG+m76ZXe28unyjBwTBYrZC
        bz6TIHDv1fCvXhVkZUGhfkHrpJkzin+rlu6gMrvhaRBtyXNeOC8okIVOMe9Dr4BW
        xA1EW2jDELdXpHIWtQBOlL76AQjgE55dcdB+osbL3UZ5+PHoIAomm+0HAzAdPvzi
        zhpOp421Txl3IeMWUWepAbdqNUp3Jyoco8dFuoNpbetZ2OtRqNti4hcgmQcGe5JC
        mzMcxgovV/UXQzR6atKQ4G9AAe7CQRvtNVh6Ebos5sFBXallqdVvEfM01OmnMvPu
        UyAIajc2b78easE=
        -----END CERTIFICATE-----


radosgw_cert_configure:
  cmd.run:
    - name: "update-ca-certificates"
    - require: 
      - file: radosgw_cert_file