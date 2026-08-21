use serde::{Deserialize, Serialize};

/// Version Release Milestone Definition
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReleaseMilestone {
    pub version: String,
    pub title: String,
    pub features: Vec<String>,
    pub status: String,
}

/// System Release Roadmap Report
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReleaseRoadmapReport {
    pub current_version: String,
    pub mvp_v01_scope: Vec<String>,
    pub milestones: Vec<ReleaseMilestone>,
}

/// Version Release Roadmap Inspector
pub struct ReleaseRoadmapInspector;

impl ReleaseRoadmapInspector {
    pub fn get_roadmap() -> ReleaseRoadmapReport {
        let mvp_v01_scope = vec![
            "✓ Register".to_string(),
            "✓ Login".to_string(),
            "✓ Create repository".to_string(),
            "✓ Local repository".to_string(),
            "✓ Git objects".to_string(),
            "✓ Hashing".to_string(),
            "✓ Chunking".to_string(),
            "✓ Peer discovery".to_string(),
            "✓ Peer connection".to_string(),
            "✓ Upload".to_string(),
            "✓ Download".to_string(),
            "✓ Integrity verification".to_string(),
            "✓ Replication".to_string(),
            "✓ Repository browser".to_string(),
        ];

        let milestones = vec![
            ReleaseMilestone {
                version: "v0.1".to_string(),
                title: "Core Proof-of-Concept P2P MVP".to_string(),
                features: mvp_v01_scope.clone(),
                status: "COMPLETED (Core MVP Proven)".to_string(),
            },
            ReleaseMilestone {
                version: "v0.2".to_string(),
                title: "Collaboration Basics".to_string(),
                features: vec![
                    "Issues Tracking".to_string(),
                    "Branches Management".to_string(),
                    "Commits DAG View".to_string(),
                    "Tag Release Marking".to_string(),
                ],
                status: "COMPLETED".to_string(),
            },
            ReleaseMilestone {
                version: "v0.3".to_string(),
                title: "Advanced Peer Workflows".to_string(),
                features: vec![
                    "Pull Requests State Machine".to_string(),
                    "Inline Code Reviews".to_string(),
                    "Repository Forks".to_string(),
                ],
                status: "COMPLETED".to_string(),
            },
            ReleaseMilestone {
                version: "v0.4".to_string(),
                title: "Security & Encryption".to_string(),
                features: vec![
                    "Private Repositories".to_string(),
                    "AES-256 Zero-Knowledge Encryption".to_string(),
                    "Public Key Access Grants".to_string(),
                ],
                status: "COMPLETED".to_string(),
            },
            ReleaseMilestone {
                version: "v0.5".to_string(),
                title: "Developer CLI".to_string(),
                features: vec![
                    "CodeHub Git CLI (`codehub clone`, `codehub push`, `codehub pull`)".to_string(),
                ],
                status: "COMPLETED".to_string(),
            },
            ReleaseMilestone {
                version: "v0.6".to_string(),
                title: "CI/CD & Event Workhooks".to_string(),
                features: vec![
                    "Sandboxed Actions / CI Runner".to_string(),
                    "Event Webhooks & Triggers".to_string(),
                ],
                status: "COMPLETED".to_string(),
            },
            ReleaseMilestone {
                version: "v1.0".to_string(),
                title: "Production Hardened Network".to_string(),
                features: vec![
                    "9-Replica Geo Seed Mesh".to_string(),
                    "Cloudflare Ingress & DDoS Protection".to_string(),
                    "Cross-Platform Flutter Desktop App".to_string(),
                ],
                status: "READY FOR LAUNCH".to_string(),
            },
        ];

        ReleaseRoadmapReport {
            current_version: "v1.0-RC".to_string(),
            mvp_v01_scope,
            milestones,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_release_roadmap_structure() {
        let roadmap = ReleaseRoadmapInspector::get_roadmap();

        assert_eq!(roadmap.mvp_v01_scope.len(), 14);
        assert_eq!(roadmap.milestones.len(), 7);

        // Verify v0.1 scope contains core features
        assert!(roadmap.mvp_v01_scope.iter().any(|f| f.contains("Register")));
        assert!(roadmap.mvp_v01_scope.iter().any(|f| f.contains("Chunking")));
        assert!(roadmap.mvp_v01_scope.iter().any(|f| f.contains("Peer discovery")));
        assert!(roadmap.mvp_v01_scope.iter().any(|f| f.contains("Repository browser")));
    }
}
