# New ports collection makefile for:	spoejs
# Date created:		26 October 2004
# Whom:			sauber@users.sourceforge.net
#
# $FREEBSD$
#

PORTNAME=	spoejs
PORTVERSION=	0.1
PORTREVISION=	2
CATEGORIES=	www
MASTER_SITES=   # none
DISTFILES=      # none
EXTRACT_ONLY=   # none

MAINTAINER=	sauber@users.sourceforge.net
COMMENT=	spoejs meta port

RUN_DEPENDS+=	${LOCALBASE}/bin/mplayer:${PORTSDIR}/multimedia/mplayer
RUN_DEPENDS+=	${SITE_PERL}/mod_perl.pm:${PORTSDIR}/www/mod_perl
RUN_DEPENDS+=	${SITE_PERL}/HTML/Mason.pm:${PORTSDIR}/www/p5-HTML-Mason
RUN_DEPENDS+=	${SITE_PERL}/Image/Magick.pm:${PORTSDIR}/graphics/ImageMagick
RUN_DEPENDS+=	${SITE_PERL}/YAML.pm:${PORTSDIR}/textproc/p5-YAML
RUN_DEPENDS+=	${SITE_PERL}/Apache/Session/File.pm:${PORTSDIR}/www/p5-Apache-Session
RUN_DEPENDS+=	${SITE_PERL}/Image/Size.pm:${PORTSDIR}/graphics/p5-Image-Size
RUN_DEPENDS+=	${SITE_PERL}/Date/Manip.pm:${PORTSDIR}/devel/p5-Date-Manip
RUN_DEPENDS+=	${SITE_PERL}/Carp/Assert.pm:${PORTSDIR}/devel/p5-Carp-Assert
RUN_DEPENDS+=	${SITE_PERL}/Video/Info.pm:${PORTSDIR}/multimedia/p5-Video-Info
RUN_DEPENDS+=	${SITE_PERL}/IO/Zlib.pm:${PORTSDIR}/archivers/p5-IO-Zlib
RUN_DEPENDS+=	${SITE_PERL}/Archive/Tar.pm:${PORTSDIR}/archivers/p5-Archive-Tar
RUN_DEPENDS+=	${SITE_PERL}/Archive/Zip.pm:${PORTSDIR}/archivers/p5-Archive-Zip
RUN_DEPENDS+=	${SITE_PERL}/HTML/FillInForm.pm:${PORTSDIR}/www/p5-HTML-FillInForm
RUN_DEPENDS+=	${SITE_PERL}/Authen/Captcha.pm:${PORTSDIR}/security/p5-Authen-Captcha

NO_BUILD=	yes

do-install:	# empty

.include <bsd.port.mk>
