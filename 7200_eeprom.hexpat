#include <std/core.pat>
#include <std/string.pat>
//#include <std/mem.pat>

u8 num_chans = 80;

struct channame {
    char name[12];
    char;
};
bitfield nib {
    low  : 4;
    hi: 4;
};

namespace type {

    /**
        Decodes a BCD value where one nibble represents a single digit
        @tparam Digits Number bytes containing digits
    */
    struct NBCD<auto Digits> {
        u8 bytes[Digits];
    } [[sealed, format_read("type::impl::format_nbcd")]];

    namespace impl {

        fn format_nbcd(ref auto nbcd) {
            str result;

            for (u32 i = 0, i < sizeof(nbcd.bytes), i += 1) {
                u8 byte = nbcd.bytes[i];
                u8 lnib = byte & 0xf;
                u8 hnib = byte >> 4;
                if (hnib >= 10 || lnib >= 10)
                    return "Invalid";

                result += std::format("{:02}", ((hnib * 10) + lnib));
            }

            return result;
        };

    }

}

char pincode[4] @0x16b4;
char manufacturername[12] @ 0x1e00;
char productname[12] @ 0x1e8f;

struct mmsi_t {
 u8 p[5] ;
} [[sealed,format("format_mmsi")]];

fn format_mmsi (ref auto mmsi) {
    return std::format("{:2d}{:2d}{:2d}{:2d}{:d}", mmsi.p[0], mmsi.p[1], mmsi.p[2], mmsi.p[3], mmsi.p[4]/10);
};

mmsi_t mmsi @0x16ac;
mmsi_t atis @ 0x16A2;

u8 chan_num_dsc[num_chans] @ 0x00 [[hidden]];
u8 num_dscchans @ 0x52 [[hidden]];
u16 chan_dsc_bf1[num_chans] @ 0x100 [[hidden]];
u16 chan_dsc_bf2[num_chans] @ 0x2f2 [[hidden]];
u16 chan_dsc_bf3[num_chans] @ 0x11a0 [[hidden]];
channame chan_names_dsc[num_chans] @ 0x500 [[hidden]];
nib chan_dsc_bf4[num_chans / 2] @ 0x1392 [[hidden]];

u8 chan_num_atis[num_chans] @ 0xAA [[hidden]];
u8 num_atischans @ 0xFC [[hidden]];
u16 chan_atis_bf1[num_chans] @ 0x1A6 [[hidden]];
u16 chan_atis_bf2[num_chans] @ 0x3a6 [[hidden]];
u16 chan_atis_bf3[num_chans] @ 0x12ec [[hidden]];
channame chan_names_atis[num_chans] @ 0xd61 [[hidden]];
nib chan_atis_bf4[num_chans / 2] @ 0x1442 [[hidden]];

u8 chan_num_can[num_chans] @ 0x55 [[hidden]];
u8 num_canchans @ 0xA7 [[hidden]];
u16 chan_can_bf1[num_chans] @ 0x24c [[hidden]];
u16 chan_can_bf2[num_chans] @ 0x45a [[hidden]];
u16 chan_can_bf3[num_chans] @ 0x1246 [[hidden]];
//bool ll_ring_off @ 0x1E4B;

enum Channeltype : u8 {
    unset = 0,
    dsc = 1,
    atis = 2
} [[sealed, format_read("format_channeltype")]];

fn format_channeltype(ref auto ct) {
    if (ct == Channeltype::dsc) {
        return "dsc";
    }
    if (ct == Channeltype::atis) {
        return "atis";
    }
    if (ct == Channeltype::unset) {
        return "unset";
    }
    return "unknown";
};


struct Channel_dsc_t {
    Channeltype type = Channeltype::dsc [[export]];
    u32 num = u32(std::core::array_index());
    type::NBCD<1> id @ (addressof(chan_num_dsc) + num) ; // 01..99
    char name[12] @ addressof(chan_names_dsc) + ( std::core::array_index() * 13) 
      [[format("std::string::to_string")]]; // uppercase ASCII
    u16 bf1 @ addressof(chan_dsc_bf1) + (2*num);
    u16 tunerx @ addressof(chan_dsc_bf2) + (2*num);
    u16 tunetx @ addressof(chan_dsc_bf3) + (2*num);
    u8 bf4 @ addressof(chan_dsc_bf4) + (num/2) [[hidden]];
    u8 bf = ((num%2) ? (bf4 & 0xf) : (bf4 >> 4)) [[export]];
};

struct Channel_atis_t {
    Channeltype type = Channeltype::atis [[export]];
    u32 num = u32(std::core::array_index());
    type::NBCD<1> id @ (addressof(chan_num_atis) + num) ; // 01..99
    char name[12] @ addressof(chan_names_atis) + ( std::core::array_index() * 13)
          [[format("std::string::to_string")]]; // uppercase ASCII
    u16 bf1 @ addressof(chan_atis_bf1) + (2*num);
    u16 tunerx @ addressof(chan_atis_bf2) + (2*num);
    u16 tunetx @ addressof(chan_atis_bf3) + (2*num);
    u8 bf4 @ addressof(chan_atis_bf4) + (num/2) [[hidden]];
    u8 bf = ((num%2) ? (bf4 & 0xf) : (bf4 >> 4)) [[export]];
};

Channel_dsc_t channels_dsc[num_dscchans] @ 0x0;
Channel_atis_t channels_atis[num_atischans] @ 0x0;