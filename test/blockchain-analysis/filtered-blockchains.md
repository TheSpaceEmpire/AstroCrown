flowchart TD
%%{init: {"theme": "default", "flowchart": {"defaultRenderer": "elk"}} }%%
    %% Title
    title[Blockchain Selection for AstroCrown]

    %% Subgraphs for Qualified and Disqualified Chains
    subgraph Qualified Chains
        direction TB
        POL[Polygon PoS]
        BNB[BNB Chain]
        AVAX[Avalanche C-Chain]
        SOL[Solana]
    end

    subgraph Disqualified Chains
        direction TB
        ARB[Arbitrum]
        OPT[Optimism]
        LIN[Linea]
        ZKE[ZKSync Era]
        SCR[Scroll]
    end

    %% Descriptions for Qualified Chains
    POL --> POL_DESC["Extremely low fees (less than $0.01)\\nHigh user base & infrastructure\\nEthereum-compatible"]
    BNB --> BNB_DESC["Fast & scalable\\nSignificant liquidity\\nBroad ecosystem support"]
    AVAX --> AVAX_DESC["Low fees\\nSubnet support\\nStrong developer community"]
    SOL --> SOL_DESC["High throughput (~65,000 TPS)\\nLow transaction fees\\nGrowing ecosystem\\nNetwork reliability concerns"]

    %% Descriptions for Disqualified Chains
    ARB --> ARB_DESC["Complex bridging\\nCentralized governance"]
    OPT --> OPT_DESC["Experimental stage\\nLimited support"]
    LIN --> LIN_DESC["Under-tested\\nBridge reliance\\nLimited documentation"]
    ZKE --> ZKE_DESC["High transaction costs\\nNot fully open-source"]
    SCR --> SCR_DESC["Early development stage\\nLimited ecosystem"]

    %% Conclusion
    POL_DESC & BNB_DESC & AVAX_DESC & SOL_DESC --> CONCLUSION["Polygon PoS, BNB Chain, Avalanche C-Chain, and Solana are well-suited for AstroCrown.\\nThey offer a balance of low fees, scalability, and community support.\\nSolana's network reliability should be monitored.\\nOther platforms were excluded due to technical or maturity concerns."]
