# encoding: utf-8

require File.dirname(__FILE__) + '/../spec_helper.rb'

describe OrdersByDay do
  describe '#filter' do
    before do
      @params = {
        'tracker_id'          => '857',
        'destination_id'      => '993',
        'order_type'          => 'parent',
        'created_at'          => '2015-04-20',
        'source_display_name' => 'Social Media',
      }
    end

    context 'When tracker_id is informed' do
      it 'use it' do
        params  = { 'tracker_id' => '857' }

        expect(OrdersByDay).to receive(:where)
                           .with(tracker_id: 857)
                           .and_return('foo')

        expect(OrdersByDay.filter params).to eql 'foo'
      end
    end

    context 'When destination_id is informed' do
      it 'use it' do
        params  = { 'destination_id' => '993' }

        expect(OrdersByDay).to receive(:where)
                           .with(destination_id: 993)
                           .and_return('foo')

        expect(OrdersByDay.filter params).to eql 'foo'
      end
    end

    context 'When order_type is informed' do
      it 'use it' do
        params  = { 'order_type' => 'parent' }

        expect(OrdersByDay).to receive(:where)
                           .with(order_type: 'parent')
                           .and_return('foo')

        expect(OrdersByDay.filter params).to eql 'foo'
      end
    end

    context 'When created_at is informed' do
      it 'use it' do
        params  = { 'created_at' => '2015-04-20' }
        date    = Date.new 2015, 4, 20

        expect(OrdersByDay).to receive(:where)
                           .with(created_at: date)
                           .and_return('foo')

        expect(OrdersByDay.filter params).to eql 'foo'
      end
    end

    context 'When source_display_name is informed' do
      it 'use it' do
        params  = { 'source_display_name' => 'Social Media' }

        expect(OrdersByDay).to receive(:where)
                           .with(source_display_name: 'Social Media')
                           .and_return('foo')

        expect(OrdersByDay.filter params).to eql 'foo'
      end
    end
  end

  describe '.dashboard' do
    it 'Match expectation' do
      expectation = {
        'Email' =>        { hits: 0, conversions: 0, avg_order_value: 0, upsells: 1, total_upsells: 25.0, sales: 7, total_sales: 857.0 },
        'Social Media'=>  { hits: 0, conversions: 0, avg_order_value: 0, upsells: 1, total_upsells: 150.0, sales: 0, total_sales: 0 }
      }

      expect(OrdersByDay.dashboard '2015-04-25').to eql expectation
    end
  end

  describe '.from_source' do
    it 'Match expectation' do
      expectation = {
        'HLV_PinAd2_Top3Myths_APP'            => { hits: 0, conversions: 0, avg_order_value: 0, upsells: 0, total_upsells: 0, sales: 1, total_sales: 35.0 },
        'HLV_PinAd3_Secrets_APP'              => { hits: 0, conversions: 0, avg_order_value: 0, upsells: 1, total_upsells: 67.0, sales: 1, total_sales: 97.0 },
        'HLV_PinAd2_Top3Myths'                => { hits: 0, conversions: 0, avg_order_value: 0, upsells: 1, total_upsells: 25.0, sales: 2, total_sales: 214.0 },
        'Youtube_HLV_Stephanie_Lange_3_16_15' => { hits: 0, conversions: 0, avg_order_value: 0, upsells: 0, total_upsells: 0, sales: 1, total_sales: 39.0 },
        'HLV_PinAd5_LongerFullerFaster'       => { hits: 0, conversions: 0, avg_order_value: 0, upsells: 0, total_upsells: 0, sales: 1, total_sales: 109.0 }
      }

      expect(OrdersByDay.from_source 'Social Media', '2015-03-19').to eql expectation
    end
  end

  describe '.tracker' do
    before do
      @params = { 'tracker_id' => '851', 'created_at' => '2015-03-11' }
    end

    it 'match with expectation' do
      expectation = '{"tracker_name":"MP_HLV_BC_HLV_4HABITS_031015","tracker_url":"http://trackers.wise-elephant.com/track/851","hits":0,"convertions":0,"upsells":2,"total_upsells":146.0,"sales":5,"total_sales":405.0}'

      expect(OrdersByDay.tracker @params).to eql expectation
    end
  end
end
