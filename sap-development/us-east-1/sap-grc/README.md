       { 
            from_port : -1, 
            to_port : -1,
            protocol : "icmp", 
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"], 
            security_groups : [],
            description : "ICM from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port : 22,
            to_port : 22, 
            protocol : "tcp", 
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"], 
            security_groups : [],
            description : "SSH from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port:  389,
            to_port : 389,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "LDAP from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },
        { 
            from_port:  443,
            to_port : 443,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "HTTPS from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port:  1128,
            to_port : 1129,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "SAP SUM from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },                          
        { 
            from_port:  3200,
            to_port : 3201,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "SAP RFC from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },
        { 
            from_port:  3299,
            to_port : 3299,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "SAP Router from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },    
        { 
            from_port:  3300,
            to_port : 3301,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "SAP Gateway from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },  
        { 
            from_port:  3638,
            to_port : 3638,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "ASE from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port:  4237,
            to_port : 4239,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "SWMP from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },    
        { 
            from_port:  4282,
            to_port : 4283,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "ASE HTTP from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port:  4800,
            to_port : 4801,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "SNC HTTP from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port:  8000,
            to_port : 8001,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "ABAP HTTP from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },
        { 
            from_port:  8100,
            to_port : 8101,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "ABAP HTTP from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port:  8200,
            to_port : 8201,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "ABAP HTTPS from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }, 
        { 
            from_port:  25000,
            to_port : 25001,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "SMTP from SAP DEV VPC, Shared Service VPC and VPN subnets."
        },                                                                       
        { 
            from_port:  55000,
            to_port : 55010,
            protocol:  "tcp",
            cidr_blocks : [],
            prefix_ids : ["pl-0e1b2690b6352b54f", "pl-06ac88f9005ecec00", "pl-0661bdcdbf90dc611"],
            security_groups : [],
            description : "ASE HTTP/S from SAP DEV VPC, Shared Service VPC and VPN subnets."
        }