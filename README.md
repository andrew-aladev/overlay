add to /etc/layman/layman.cfg
    
    overlays  : http://www.gentoo.org/proj/en/overlays/repositories.xml
                file:///var/lib/layman/my-list.xml

add to /var/lib/layman/my-list.xml

    <?xml version="1.0" ?>
    <repositories version="1.0">
      <repo priority="50" quality="experimental" status="unofficial">
        <name>puchuu</name>
        <description>Puchuu ebuilds.</description>
        <homepage>https://github.com/andrew-aladev/puchuu-overlay</homepage>
        <owner>
          <email>aladjev.andrew@gmail.com</email>
        </owner>
        <source type="git">git://github.com/andrew-aladev/puchuu-overlay.git</source>
      </repo>
    </repositories>

layman -a puchuu && eix-update
