CREATE TABLE Products (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          name VARCHAR(255),
                          description TEXT,
                          category VARCHAR(255),
                          image VARCHAR(255),
                          status VARCHAR(50)
);

CREATE TABLE Tags (
                      id INT AUTO_INCREMENT PRIMARY KEY,
                      tag VARCHAR(50) UNIQUE
);

CREATE TABLE ProductTags (
                             product_id INT,
                             tag_id INT,
                             FOREIGN KEY (product_id) REFERENCES Products(id),
                             FOREIGN KEY (tag_id) REFERENCES Tags(id)
);

CREATE TABLE Restrictions (
                              id INT AUTO_INCREMENT PRIMARY KEY,
                              product_id INT,
                              type VARCHAR(50),
                              subtype VARCHAR(50),
                              value INT,
                              FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE Types (
                       id INT AUTO_INCREMENT PRIMARY KEY,
                       product_id INT,
                       name VARCHAR(255),
                       price DECIMAL(10, 2),
                       status VARCHAR(50),
                       currency VARCHAR(10),
                       FOREIGN KEY (product_id) REFERENCES Products(id)
);

CREATE TABLE Distributions (
                               id INT AUTO_INCREMENT PRIMARY KEY,
                               type_id INT,
                               name VARCHAR(255),
                               amount DECIMAL(10, 2),
                               FOREIGN KEY (type_id) REFERENCES Types(id)
);
