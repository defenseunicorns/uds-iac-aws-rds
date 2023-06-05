package test

import (
  "testing"

  "github.com/gruntwork-io/terratest/modules/aws"
  "github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const testDir = "../examples/complete"
const expectedDbName = "terratestdb"
const expectedPort = int64(4321) // terratest will return int64
const vpcName = "terratest-vpc"

const dbNameVar = "db_name"
const vpcNameVar = "vpc_name"
const portVar = "port"
const regionVar = "region"

func TestExampleComplete(t *testing.T) {
  t.Parallel()

  awsRegion := aws.GetRandomStableRegion(t, nil, nil)

  terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
    TerraformDir: testDir,

    Vars: map[string]interface{}{
      dbNameVar: expectedDbName,
      vpcNameVar: vpcName,
      portVar: expectedPort,
      regionVar: awsRegion,
    },

    NoColor: true,
  })

  defer terraform.Destroy(t, terraformOptions)

  terraform.InitAndApply(t, terraformOptions)

  dbInstanceId := terraform.Output(t, terraformOptions, "db_instance_id")

  // Get actual values
  // Look up the endpoint address and port of the RDS instance
	actualAddress := aws.GetAddressOfRdsInstance(t, dbInstanceId, awsRegion)
	actualPort := aws.GetPortOfRdsInstance(t, dbInstanceId, awsRegion)

  // Verify that the address is not null
	assert.NotNil(t, actualAddress)
	// Verify that the DB instance is listening on the port mentioned
	assert.Equal(t, expectedPort, actualPort)
}
