require 'spec_helper'
module SamlIdp
  describe SamlResponse do
    let(:reference_id) { "123" }
    let(:response_id) { "abc" }
    let(:issuer_uri) { "localhost" }
    let(:name_id) { "name" }
    let(:audience_uri) { "localhost/audience" }
    let(:saml_request_id) { "abc123" }
    let(:saml_acs_url) { "localhost/acs" }
    let(:algorithm) { :sha1 }
    let(:secret_key) { Default::SECRET_KEY }
    let(:x509_certificate) { Default::X509_CERTIFICATE }
    let(:xauthn) { Default::X509_CERTIFICATE }
    let(:authn_context_classref) {
      Saml::XML::Namespaces::AuthnContext::ClassRef::PASSWORD
    }
    let(:expiry) { 3 * 60 * 60 }
    let(:session_expiry) { 24 * 60 * 60 }
    let (:encryption_opts) do
      {
        cert: Default::X509_CERTIFICATE,
        block_encryption: 'aes256-cbc',
        key_transport: 'rsa-oaep-mgf1p',
      }
    end
    let(:signed_response_opts) { true }
    let(:unsigned_response_opts) { false }
    let(:subject_encrypted) { described_class.new(reference_id,
                                  response_id,
                                  issuer_uri,
                                  name_id,
                                  audience_uri,
                                  saml_request_id,
                                  saml_acs_url,
                                  algorithm,
                                  authn_context_classref,
                                  expiry,
                                  encryption_opts,
                                  session_expiry,
                                  unsigned_response_opts
                                 )
    }

    subject { described_class.new(reference_id,
                                  response_id,
                                  issuer_uri,
                                  name_id,
                                  audience_uri,
                                  saml_request_id,
                                  saml_acs_url,
                                  algorithm,
                                  authn_context_classref,
                                  expiry,
                                  nil,
                                  session_expiry,
                                  signed_response_opts
                                 )
    }

    before do
      Timecop.freeze(Time.local(1990, "jan", 1))
    end

    after do
      Timecop.return
    end

    it "has a valid build" do
      expect(subject.build).to be_present
    end

    it "builds encrypted" do
      expect(subject_encrypted.build).to_not match(audience_uri)
      encoded_xml = subject_encrypted.build
      resp_settings = saml_settings(saml_acs_url)
      resp_settings.private_key = Default::SECRET_KEY
      resp_settings.issuer = audience_uri
      saml_resp = OneLogin::RubySaml::Response.new(encoded_xml, settings: resp_settings)
      saml_resp.soft = false
      expect(saml_resp.is_valid?).to eq(true)
    end

    it "sets session expiration" do
      saml_resp = OneLogin::RubySaml::Response.new(subject.build)
      expect(saml_resp.session_expires_at).to eq Time.local(1990, "jan", 2).iso8601
    end

    context "session expiration is set to 0" do
      let(:session_expiry) { 0 }

      it "builds a valid request" do
        resp_settings = saml_settings(saml_acs_url)
        resp_settings.issuer = audience_uri
        saml_resp = OneLogin::RubySaml::Response.new(subject.build, settings: resp_settings)
        expect(saml_resp.is_valid?).to eq(true)
      end

      it "doesn't set a session expiration" do
        resp_settings = saml_settings(saml_acs_url)
        resp_settings.issuer = audience_uri
        saml_resp = OneLogin::RubySaml::Response.new(subject.build, settings: resp_settings)
        expect(saml_resp.session_expires_at).to be_nil
      end
    end
  end
end
