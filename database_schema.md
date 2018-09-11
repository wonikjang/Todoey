< Ovrall Structure >

[Database]
  - Objects
  - Collections
  - Users

[Storage]
  - Collections
  - Users



< Specific Structure>

[Database]

- Collections
  - CollectionName (Africa)
    - FileName (Tiger)
      - pathTo3D
      - pathToBack
      - CategoryName

    - FileName (Lion)
      - pathTo3D
      - pathToBack


  - Obejcts
    - Category (Animal)
      - FileName (Tiger)
        - pathTo3D:
        - pathToBack:
        - CollectionName : (Africa)

      - Lion


  - Users
    - Uid (Anonymously Created)
        - CollectionName (Africa)
          - FileName (Tiger)
            - Done : True
            - pathTo3D:
            - pathToBack:
          - FileName (Lion)
            - Done : False
            - pathTo3D
            - pathToBack


// 공통 [Upload file to Firebase]

Storage에 Upload 할때, Database에 Collections 와 Obejcts 둘 다 업데이트!




// Database & Storage 접근 및 Upload  by Flow


// Case 1 : Category 탭 안에서 들어갈 경우

1. Database[objects]
  Catgegory / FileName 을 전달 받아
    1.1. CollectionName 을 저장
    1.2. pathTo3D, pathToBack 내용으로 Storage 접근해서 화면에 보여주기                                  

2. Database[Users]
  저장된 CollectionName 과 FileName 을 위 과정에서 전달 받아
    2.1. Database[Uesrs] Update:
      Done: False
      pathTo3D : Storage[Users] / CollectionName / FileName /
      pathToBack :  Storage[Users] / CollectionName / FileName /
    2.2. Storage[Users] / CollectionName / FileName / 안에 작업중인 3D Object 파일들 저장



// Case 2 : Collection 탭 안에서 들어갈 경우

1. Database[Collections]
  CollectionName / FileName 을 전달 받아 pathTo3D, pathToBack 내용으로 Storage 접근

2. Database[User]
  CollectionName / FileName 을 전달 받아
  2.1. Database[Uesrs] Update:
    Done: False
    pathTo3D : Storage[Users] / CollectionName / FileName /
    pathToBack :  Storage[Users] / CollectionName / FileName /
  2.2. Storage[Users] / CollectionName / FileName / 안에 작업중인 3D Object 파일들 저장


// 색칠을 완료 했을 경우, if Done: false --> True 가 될 경우

1. Database[Users]
  색칠 화면에서 완료시 CollectionName / FileName 을 가지고 접근하여,
  Done: false --> True

2. Storage[Users]
  2.1. Storage[Users] / CollectionName / FileName / 제거
  2.2. Storage[CollectionName] / FileName / 3d  및 Storage[CollectionName] / FileName / back
       을 Database[Users] pathTo3D, pathToBack 으로 저장
       --> 여러 유저가 여러파일들을 색칠할 경우, Traffic이 상당할 것

  혹은,
2'. Storage[Users] 에
  유저마다 색칠한 파일들을 가지고 있도록...
   --> 여러 유저가 여러 파일들을 색칠할 경우, 데이터 홀딩하는 양이 많을 듯
