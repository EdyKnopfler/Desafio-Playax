require_relative 'pdf_ecad_importer'

describe PdfEcadImporter do
  it 'lists all works' do
    importer = described_class.new('careqa.pdf')
      
    expect(importer.works.count).to eq 130
    expect(importer.works[0][:iswc]).to eq 'T-039.782.970-7'
    expect(importer.works.last[:external_ids][0][:source_id]).to eq '126227'
    expect(importer.works[9][:right_holders].size).to eq 4
    expect(importer.works[9][:right_holders][2][:share]).to eq 25.00
  end

  it 'recognizes a right holder for 100% line' do
    line = '4882         CARLOS DE SOUZA                        CARLOS CAREQA            582.66.28.18 ABRAMUS          CA   100,                        1'
    right_holder = described_class.right_holder(line)

    expect(right_holder[:name]).to eq 'CARLOS DE SOUZA'
    expect(right_holder[:pseudos][0][:name]).to eq 'CARLOS CAREQA'
    expect(right_holder[:pseudos][0][:main]).to eq true
    expect(right_holder[:role]).to eq 'Author'
    expect(right_holder[:society_name]).to eq 'ABRAMUS'
    expect(right_holder[:ipi]).to eq '582662818'
    expect(right_holder[:external_ids][0][:source_name]).to eq 'Ecad'
    expect(right_holder[:external_ids][0][:source_id]).to eq '4882'
    expect(right_holder[:share]).to eq 100
  end

  it 'recognizes share for broken percent' do
    line = '16863        EDILSON DEL GROSSI FONSECA             EDILSON DEL GROSSI                     SICAM           CA 33,33                         2'
    right_holder = described_class.right_holder(line)

    expect(right_holder[:name]).to eq 'EDILSON DEL GROSSI FONSECA'
    expect(right_holder[:share]).to eq 33.33
    expect(right_holder[:ipi]).to be_nil
  end

  it 'recognizes share in right holder line' do
    line = '741          VELAS PROD. ARTISTICAS MUSICAIS E      VELAS                    247.22.09.80 ABRAMUS           E   8,33 20/09/95               2'
    right_holder = described_class.right_holder(line)

    expect(right_holder[:name]).to eq 'VELAS PROD. ARTISTICAS MUSICAIS E'
    expect(right_holder[:share]).to eq 8.33
  end

  it 'returns nil if it is not a right_holder' do
    line = '3810796       -   .   .   -          O RESTO E PO                                                LB             18/03/2010'
    right_holder = described_class.right_holder(line)

    expect(right_holder).to be_nil
  end

  it 'recognizes work in line' do
    line = '3810796       -   .   .   -          O RESTO E PO                                                LB             18/03/2010'
    work = described_class.work(line)

    expect(work).not_to be_nil
    expect(work[:iswc]).to eq '-   .   .   -'
    expect(work[:title]).to eq 'O RESTO E PO'
    expect(work[:external_ids][0][:source_name]).to eq 'Ecad'
    expect(work[:external_ids][0][:source_id]).to eq '3810796'
    expect(work[:situation]).to eq 'LB'
    expect(work[:created_at]).to eq '18/03/2010'
  end
  
  it 'returns nil if it is not a work' do
    line = '16863        EDILSON DEL GROSSI FONSECA             EDILSON DEL GROSSI                     SICAM           CA 33,33                         2'
    work = described_class.work(line)
    expect(work).to be_nil
  end
end
