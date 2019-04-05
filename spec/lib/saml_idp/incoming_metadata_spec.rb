require 'spec_helper'
module SamlIdp

  metadata_1 = <<-eos
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="test" entityID="https://test-saml.com/saml">
  <md:SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol" AuthnRequestsSigned="true" WantAssertionsSigned="false">
  </md:SPSSODescriptor>
</md:EntityDescriptor>
  eos

  metadata_2 = <<-eos
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="test" entityID="https://test-saml.com/saml">
  <md:SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol" AuthnRequestsSigned="true" WantAssertionsSigned="true">
  </md:SPSSODescriptor>
</md:EntityDescriptor>
  eos

  metadata_3 = <<-eos
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="test" entityID="https://test-saml.com/saml">
  <md:SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol" AuthnRequestsSigned="true">
  </md:SPSSODescriptor>
</md:EntityDescriptor>
  eos

  metadata_saml1 = <<-eos
<?xml version="1.0"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" validUntil="2019-04-07T08:23:29Z" cacheDuration="PT604800S" entityID="test">
    <md:SPSSODescriptor AuthnRequestsSigned="true" WantAssertionsSigned="true" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
        <md:SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://test/logout" />
        <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat>
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://test/acs" index="0" />
        <md:AssertionConsumerService Binding="urn:oasis:names:tc:SAML:1.0:profiles:browser-post" Location="https://test/acs" index="1"/>
    </md:SPSSODescriptor>
</md:EntityDescriptor>
  eos

  describe IncomingMetadata do
    let(:test_metadata) {}
    subject { SamlIdp::IncomingMetadata.new(test_metadata) }

    context 'false sign_assertions' do
      let(:test_metadata) { metadata_1 }

      it 'should properly set sign_assertions to false' do
        expect(subject.sign_assertions).to eq(false)
      end
    end

    context 'true sign_assertions' do
      let(:test_metadata) { metadata_2 }

      it 'should properly set sign_assertions to true' do
        expect(subject.sign_assertions).to eq(true)
      end
    end

    context 'no sign_assertions' do
      let(:test_metadata) { metadata_3 }

      it 'should properly set sign_assertions to false when WantAssertionsSigned is not included' do
        expect(subject.sign_assertions).to eq(false)
      end
    end

    context 'entity_id' do
      let(:test_metadata) { metadata_1 }

      it 'should extract entity id as string' do
        expect(subject.entity_id).to be_a(String)
      end
    end

    context 'acs' do
      let(:test_metadata) { metadata_saml1 }

      it 'should ignore saml 1.0 attributes' do
        expect { subject.assertion_consumer_services }.not_to raise_error
      end
    end
  end
end
