package test

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ecs"
	"github.com/aws/aws-sdk-go/service/ssm"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"net/http"
	"testing"
)

const region = "us-west-1"
const dns = "terraform-aws-app.oss.champtest.net"

// TestExamplesComplete tests a typical deployment of this module
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:  "../../examples/complete",
		BackendConfig: map[string]interface{}{},
		EnvVars:       map[string]string{},
		Vars:          map[string]interface{}{},
	}
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApplyAndIdempotent(t, terraformOptions)

	checkSSM(t, terraformOptions)
	checkHTTP(t)
}

func checkSSM(t *testing.T, terraformOptions *terraform.Options) {
	logger.Log(t, "Creating AWS Session")
	awsSess := GetAWSSession()

	taskDefinitionArn := terraform.Output(t, terraformOptions, "task_definition_arn")
	taskDefinition := getTaskDefinition(awsSess, region, taskDefinitionArn)

	// For each secret set on the container, go get the plaintext value out of SSM and compare it to what it should be
	actualKmsValue1 := getContainerSSMValue(awsSess, region, taskDefinition, "KMSTEST1")
	assert.Equal(t, "kms secret 1", actualKmsValue1)

	actualKmsValue2 := getContainerSSMValue(awsSess, region, taskDefinition, "KMSTEST2")
	assert.Equal(t, "kms secret 2", actualKmsValue2)

	actualSsmValue1 := getContainerSSMValue(awsSess, region, taskDefinition, "SSMTEST1")
	assert.Equal(t, "ssm secret 1", actualSsmValue1)

	actualSsmValue2 := getContainerSSMValue(awsSess, region, taskDefinition, "SSMTEST2")
	assert.Equal(t, "kms secret 2", actualSsmValue2) // Test overriding a ssm "secret" with a "kms_secret"
}

func checkHTTP(t *testing.T) {
	logger.Log(t, "Running HTTP GET for:", dns)
	resp, err := http.Get(fmt.Sprintf("https://%s/", dns))
	assert.Nil(t, err)
	assert.Equal(t, 200, resp.StatusCode)
}

// GetAWSSession Logs in to AWS and return a session
func GetAWSSession() *session.Session {
	fmt.Println("Getting AWS Session")
	sess, err := session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	})
	if err != nil {
		panic(err)
	}
	return sess
}

// GetSSMParameter fetches and returns an SSM parameter with fields such as Value and Type
func GetSSMParameter(session *session.Session, region string, name string) *ssm.Parameter {
	fmt.Println("Getting SSM parameter:", name)
	svc := ssm.New(session, aws.NewConfig().WithRegion(region))
	res, err := svc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String(name),
		WithDecryption: aws.Bool(true),
	})
	if err != nil {
		panic(err)
	}
	return res.Parameter
}

// getTaskDefinition fetches the ECS task definition using the specified ARN, which must include family and revision
func getTaskDefinition(session *session.Session, region string, taskDefinitionArn string) *ecs.TaskDefinition {
	fmt.Println("Getting ECS task definition:", taskDefinitionArn)
	svc := ecs.New(session, aws.NewConfig().WithRegion(region))
	res, err := svc.DescribeTaskDefinition(&ecs.DescribeTaskDefinitionInput{
		TaskDefinition: aws.String(taskDefinitionArn),
	})
	if err != nil {
		panic(err)
	}
	return res.TaskDefinition
}

// getContainerSSMValue looks through the secrets set on the container for the name specified. Then it gets the actual
// plaintext string of the secret by querying SSM directly
func getContainerSSMValue(session *session.Session, region string, taskDefinition *ecs.TaskDefinition, name string) string {
	for _, secret := range taskDefinition.ContainerDefinitions[0].Secrets {
		if *secret.Name == name {
			param := GetSSMParameter(session, region, *secret.ValueFrom)
			fmt.Printf("Value of SSM param %s: %s\n", *secret.ValueFrom, *param.Value)
			return *param.Value
		}
	}
	return ""
}
