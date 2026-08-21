use serde::{Deserialize, Serialize};

/// 7 Pillars of CodeHub Product Differentiation
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ProductPillarSpec {
    pub pillar: String,
    pub description: String,
}

/// Product Positioning Blueprint Report
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProductPositioningReport {
    pub weak_pitch: String,
    pub strong_pitch: String,
    pub differentiation_pillars: Vec<ProductPillarSpec>,
    pub hybrid_value_proposition: String,
}

/// Product Positioning Inspector Engine
pub struct ProductPositioningInspector;

impl ProductPositioningInspector {
    pub fn get_positioning() -> ProductPositioningReport {
        let pillars = vec![
            ProductPillarSpec {
                pillar: "1. Git-like Developer Platform".to_string(),
                description: "Familiar Pull Requests, Issues, Code Browser, Commits, and Branch workflows.".to_string(),
            },
            ProductPillarSpec {
                pillar: "2. Device Storage Utilization".to_string(),
                description: "Leverages local peer SSD/NVMe disk space to decentralize storage burden.".to_string(),
            },
            ProductPillarSpec {
                pillar: "3. P2P Repository Replication".to_string(),
                description: "BitSwap DAG-aware chunk distribution across active peer swarms.".to_string(),
            },
            ProductPillarSpec {
                pillar: "4. Centralized Identity & Permissions Control Plane".to_string(),
                description: "Seamless JWT auth, team permissions, and zero-friction user access management.".to_string(),
            },
            ProductPillarSpec {
                pillar: "5. Automatic Geo-Replication Mesh".to_string(),
                description: "9-Replica seed mesh (Owner + 3 Geo Seeds + 5 Community Peers) guaranteeing 99.999% SLA durability.".to_string(),
            },
            ProductPillarSpec {
                pillar: "6. Real-Time Repository Health Diagnostics".to_string(),
                description: "Continuous replication health score checks (0-100%) and auto-healing re-replication.".to_string(),
            },
            ProductPillarSpec {
                pillar: "7. Cross-Platform Flutter Client & Zero-Config CLI".to_string(),
                description: "Native Desktop GUI (Linux, macOS, Windows) + CLI for instant developer onboarding.".to_string(),
            },
        ];

        ProductPositioningReport {
            weak_pitch: "I made GitHub using torrent.".to_string(),
            strong_pitch: "A developer platform where repositories are distributed across a peer network instead of depending entirely on centralized repository storage.".to_string(),
            differentiation_pillars: pillars,
            hybrid_value_proposition: "Combines the control plane reliability of GitHub with the decentralized durability, cost-efficiency, and privacy of P2P storage networks.".to_string(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_product_positioning_and_differentiation() {
        let positioning = ProductPositioningInspector::get_positioning();

        assert_eq!(positioning.differentiation_pillars.len(), 7);
        assert!(positioning.strong_pitch.contains("distributed across a peer network"));
        assert!(!positioning.strong_pitch.contains("torrent"));
    }
}
