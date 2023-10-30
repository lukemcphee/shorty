CREATE TABLE entry (
    short_url varchar(50),
    target_url varchar(50),
    PRIMARY KEY(short_url,target_url)
);
