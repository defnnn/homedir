def test_kubernetes_version(kind_cluster):
    assert kind_cluster.api.version == ('1', '18')
