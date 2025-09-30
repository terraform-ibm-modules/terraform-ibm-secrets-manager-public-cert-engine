// Tests in this file are run in the PR pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/IBM/go-sdk-core/core"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
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
const fullyConfigurableDir = "solutions/fully-configurable"
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
		{Name: "existing_sm_instance_crn", Value: permanentResources["privateOnlySecMgrCRN"], DataType: "string"},
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

func TestRunSolutionsFullyConfigurableSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sm-pb",
		TarIncludePatterns: []string{
			"*.tf",
			fullyConfigurableDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         fullyConfigurableDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_secrets_manager_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "acme_letsencrypt_private_key_secrets_manager_secret_crn", Value: permanentResources["acme_letsencrypt_private_key_secret_crn"], DataType: "string"},
		{Name: "skip_iam_authorization_policy", Value: true, DataType: "bool"}, // A permanent cis-sm auth policy already exists in the account
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunSolutionsFullyConfigurableUpgradeSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sm-pb-up",
		TarIncludePatterns: []string{
			"*.tf",
			fullyConfigurableDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         fullyConfigurableDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_secrets_manager_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
		{Name: "acme_letsencrypt_private_key_secrets_manager_secret_crn", Value: permanentResources["acme_letsencrypt_private_key_secret_crn"], DataType: "string"},
		{Name: "dns_config_name", Value: "cer-dns", DataType: "string"},
		{Name: "internet_services_crn", Value: permanentResources["cisInstanceId"], DataType: "string"},
		{Name: "skip_iam_authorization_policy", Value: true, DataType: "bool"}, // A permanent cis-sm auth policy already exists in the account
	}

	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
}

func TestPlanValidation(t *testing.T) {

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  fullyConfigurableDir,
		Prefix:        "val-plan",
		ResourceGroup: resourceGroup,
	})
	options.TestSetup()
	options.TerraformOptions.NoColor = true
	options.TerraformOptions.Logger = logger.Discard
	options.TerraformOptions.Vars = map[string]interface{}{
		"prefix":                       options.Prefix,
		"existing_secrets_manager_crn": permanentResources["secretsManagerCRN"],
		"acme_letsencrypt_private_key_secrets_manager_secret_crn": permanentResources["acme_letsencrypt_private_key_secret_crn"], // pragma: allowlist secret
		"skip_iam_authorization_policy":                           true,
		"provider_visibility":                                     "public",
	}

	// Init
	_, initErr := terraform.InitE(t, options.TerraformOptions)
	assert.Nil(t, initErr, "Terraform init should not error")

	// Plan
	planOutput, planErr := terraform.PlanE(t, options.TerraformOptions)
	assert.Nil(t, planErr, "Terraform plan should not error")
	assert.NotNil(t, planOutput, "Expected Terraform plan output")
}

func TestSecretManagerDefaultConfiguration(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "pbsme",
		ResourceGroup: resourceGroup,
		QuietMode:     false, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-secrets-manager-public-cert-engine",
		"fully-configurable",
		map[string]interface{}{
			"prefix": options.Prefix,
			"acme_letsencrypt_private_key_secrets_manager_secret_crn": permanentResources["acme_letsencrypt_private_key_secret_crn"], // pragma: allowlist secret
			"secrets_manager_region":                                  "eu-de",
			"secrets_manager_service_plan":                            "__NULL__",
			"skip_iam_authorization_policy":                           true,
		},
	)

	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		{
			OfferingName:   "deploy-arch-ibm-secrets-manager",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"existing_secrets_manager_crn":         permanentResources["secretsManagerCRN"],
				"service_plan":                         "__NULL__",
				"skip_secrets_manager_iam_auth_policy": true,
				"secret_groups":                        []string{},
			},
			Enabled: core.BoolPtr(true),
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}
