
resource "aws_iam_policy" "load-balancer-policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS LoadBalancer Controller IAM Policy"

  policy = file("iam_policy.json")
}

resource "null_resource" "post-policy" {
  depends_on = [aws_iam_policy.load-balancer-policy, module.my-cluster]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    on_failure  = fail
    interpreter = ["/bin/bash", "-c"]
    when        = create
    command     = <<EOT
        chmod +x post-policy.sh
        reg=$(echo ${var.aws_region})
        cn=$(echo ${data.aws_eks_cluster.jumia-cluster.name})
        arnpolicy=$(echo ${aws_iam_policy.load-balancer-policy.arn})
        kubeconfigpath=$(echo ${var.local_kubeconfig_path})
        image_repo_aws_load_balancer_controller=(echo ${var.image_repo_aws_load_balancer_controller})
        echo "$reg $cn $arnpolicy $kubeconfigpath"
        ./post-policy.sh $reg $cn $arnpolicy $kubeconfigpath
        echo "done"
     EOT
  }
}