// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

// Resource groups are maintained https://github.ibm.com/GoldenEye/ge-dev-account-management
const resourceGroup = "geretain-test-sm-pub-cert-eng"

const keyExampleTerraformDir = "examples/api_key_auth"
const IAMExampleTerraformDir = "examples/iam_auth"
const bestRegionYAMLPath = "../common-dev-assets/common-go-assets/cloudinfo-region-secmgr-prefs.yaml"

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"cis_id": permanentResources["cisInstanceId"],
			"private_key_secrets_manager_instance_guid": permanentResources["acme_letsencrypt_private_key_sm_id"],
			"private_key_secrets_manager_secret_id":     permanentResources["acme_letsencrypt_private_key_secret_id"],
			"private_key_secrets_manager_region":        permanentResources["acme_letsencrypt_private_key_sm_region"],
		},
		BestRegionYAMLPath: bestRegionYAMLPath,
	})

	return options
}

func TestPrivateInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sm-pub-crt-eng-prv",
		TarIncludePatterns: []string{
			"*.tf",
			keyExampleTerraformDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         keyExampleTerraformDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
		BestRegionYAMLPath:     bestRegionYAMLPath,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "cis_id", Value: permanentResources["cisInstanceId"], DataType: "string"},
		{Name: "private_key_secrets_manager_instance_guid", Value: permanentResources["acme_letsencrypt_private_key_sm_id"], DataType: "string"},
		{Name: "private_key_secrets_manager_secret_id", Value: permanentResources["acme_letsencrypt_private_key_secret_id"], DataType: "string"},
		{Name: "private_key_secrets_manager_region", Value: permanentResources["acme_letsencrypt_private_key_sm_region"], DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunIAMExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sm-public-eng-iam", IAMExampleTerraformDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sm-pub-cert-eng-upg", IAMExampleTerraformDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
